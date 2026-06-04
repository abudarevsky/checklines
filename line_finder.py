#!/usr/bin/env python3
"""
Script to analyze trap reachability on an 8x8 chessboard.
"""

import sys
import json
from typing import List, Tuple, Set, Dict


# Godot constants
BOARD_SIZE = 8


def parse_board(input_data: str) -> List[List[str]]:
    """Parse a JSON string or file path into an 8x8 board."""
    try:
        # Try parsing as JSON string first
        board_data = json.loads(input_data)
    except json.JSONDecodeError:
        # If that fails, try reading as a file path
        try:
            with open(input_data, 'r') as f:
                board_data = json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            raise ValueError("Input must be a valid JSON string or a valid file path to a JSON file")
    
    # Validate board dimensions
    if not isinstance(board_data, list) or len(board_data) != BOARD_SIZE:
        raise ValueError(f"Board must be {BOARD_SIZE}x{BOARD_SIZE}")
    
    for i, row in enumerate(board_data):
        if not isinstance(row, list) or len(row) != BOARD_SIZE:
            raise ValueError(f"Board must be {BOARD_SIZE}x{BOARD_SIZE}")
        for j, cell in enumerate(row):
            if not isinstance(cell, str):
                raise ValueError(f"Cell at position ({i}, {j}) must be a string")
            # Allow any non-empty string, but preserve special handling for 'trap'
            if cell == 'trap':
                # Trap validation already handled by the special case below
                pass
            elif cell == '':
                raise ValueError(f"Cell at position ({i}, {j}) cannot be empty string")
    
    return board_data


def get_trap_reachable_cells(row: int, col: int, board: List[List[str]]) -> Set[Tuple[int, int]]:
    """Get all cells reachable by a trap using queen-style ray casting."""
    # A trap has queen-like movement, so we use queen moves
    reachable = set()
    directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    
    # Include the trap's own cell
    reachable.add((row, col))
    
    for dr, dc in directions:
        new_row, new_col = row + dr, col + dc
        while 0 <= new_row < BOARD_SIZE and 0 <= new_col < BOARD_SIZE:
            reachable.add((new_row, new_col))
            # Stop if occupied (including by another trap)
            if board[new_row][new_col] != '':
                break
            new_row += dr
            new_col += dc
    
    return reachable


def get_all_lines() -> List[List[Tuple[int, int]]]:
    """Get all 18 lines on the 8x8 board."""
    lines = []
    
    # 8 rows
    for i in range(BOARD_SIZE):
        lines.append([(i, j) for j in range(BOARD_SIZE)])
    
    # 8 columns
    for j in range(BOARD_SIZE):
        lines.append([(i, j) for i in range(BOARD_SIZE)])
    
    # 2 main diagonals
    lines.append([(i, i) for i in range(BOARD_SIZE)])  # top-left to bottom-right
    lines.append([(i, BOARD_SIZE - 1 - i) for i in range(BOARD_SIZE)])  # top-right to bottom-left
    
    return lines


def get_full_lines_not_reachable_by_any_trap(board: List[List[str]], trap_reachables: List[Set[Tuple[int, int]]]) -> List[List[Tuple[int, int]]]:
    """Find full board lines that are not reachable by any trap."""
    all_lines = get_all_lines()
    inaccessible = []
    
    for line in all_lines:
        # Check if any trap can reach this line
        line_cells = set(line)
        reachable_by_any_trap = False
        
        for reachable in trap_reachables:
            if line_cells.issubset(reachable):
                reachable_by_any_trap = True
                break
        
        if not reachable_by_any_trap:
            inaccessible.append(line)
    
    return inaccessible


def find_trap_lines(board: List[List[str]]) -> Tuple[Dict[str, List[List[Tuple[int, int]]]], List[List[Tuple[int, int]]]]:
    """Find all lines each trap can reach and inaccessible full lines."""
    trap_positions = []
    
    # Find all trap positions
    for i in range(BOARD_SIZE):
        for j in range(BOARD_SIZE):
            if board[i][j] == 'trap':
                trap_positions.append((i, j))
    
    trap_reachables = []
    trap_lines = {}
    
    # For each trap, find reachable cells and lines
    for i, (trap_row, trap_col) in enumerate(trap_positions):
        reachable_cells = get_trap_reachable_cells(trap_row, trap_col, board)
        trap_reachables.append(reachable_cells)
        
        # Create a unique id for each trap
        trap_id = f"trap_{i}"
        trap_lines[trap_id] = []
        
        # Get all rows and columns that have cells reachable by this trap
        rows_with_reach = set()
        cols_with_reach = set()
        
        # Collect all rows and columns that contain reachable cells
        for r, c in reachable_cells:
            rows_with_reach.add(r)
            cols_with_reach.add(c)
        
        # Get lines for rows that are completely reachable
        for r in rows_with_reach:
            row_cells = [(r, c) for c in range(BOARD_SIZE) if (r, c) in reachable_cells]
            if len(row_cells) > 1:
                trap_lines[trap_id].append(row_cells)
        
        # Get lines for columns that are completely reachable
        for c in cols_with_reach:
            col_cells = [(r, c) for r in range(BOARD_SIZE) if (r, c) in reachable_cells]
            if len(col_cells) > 1:
                trap_lines[trap_id].append(col_cells)
        
        # Diagonal lines
        main_diag_cells = [(i, i) for i in range(BOARD_SIZE) if (i, i) in reachable_cells]
        if len(main_diag_cells) > 1:
            trap_lines[trap_id].append(main_diag_cells)
            
        anti_diag_cells = [(i, BOARD_SIZE - 1 - i) for i in range(BOARD_SIZE) if (i, BOARD_SIZE - 1 - i) in reachable_cells]
        if len(anti_diag_cells) > 1:
            trap_lines[trap_id].append(anti_diag_cells)
    
    # Find lines not reachable by any trap
    inaccessible_lines = get_full_lines_not_reachable_by_any_trap(board, trap_reachables)
    
    return trap_lines, inaccessible_lines


def main():
    """Main entry point for the script."""
    if len(sys.argv) < 2:
        print("Usage: python line_finder.py <board_json_file_or_string>")
        sys.exit(1)
    
    input_data = sys.argv[1]
    
    try:
        board = parse_board(input_data)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)
    
    # Find trap lines and inaccessible lines
    trap_lines, inaccessible_lines = find_trap_lines(board)
    
    # Print trap reachability section
    print("Trap Reachability:")
    for trap_id, lines in trap_lines.items():
        line_count = len(lines)
        print(f"{trap_id}: {line_count} lines")
        for line in lines:
            formatted_line = " ".join([f"({r},{c})" for r, c in line])
            print(f"  {formatted_line}")
    
    # Print inaccessible full lines section
    if inaccessible_lines:
        print("Inaccessible Full Lines:")
        for line in inaccessible_lines:
            formatted_line = " ".join([f"({r},{c})" for r, c in line])
            print(f"  {formatted_line}")
    else:
        print("Inaccessible Full Lines:")
        print("  None")


if __name__ == "__main__":
    main()