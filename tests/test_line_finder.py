#!/usr/bin/env python3
"""
Unit tests for line_finder.py
"""

import unittest
import sys
import os
import io
from contextlib import redirect_stdout

# Add the current directory to path to import line_finder
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import line_finder


class TestLineFinder(unittest.TestCase):

    def test_parse_valid_board(self):
        """Test parsing a valid board."""
        board_json = '''[
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"]
        ]'''

        board = line_finder.parse_board(board_json)
        self.assertEqual(len(board), 8)
        self.assertEqual(len(board[0]), 8)
        self.assertEqual(board[0][6], "trap")

    def test_parse_invalid_board_size(self):
        """Test parsing an invalid board size."""
        board_json = '''[
            ["pawn", "knight"],
            ["queen", "bishop"]
        ]'''

        with self.assertRaises(ValueError):
            line_finder.parse_board(board_json)

    def test_parse_invalid_piece_type(self):
        """Test parsing an invalid piece type - should reject empty strings."""
        board_json = '''[
            ["pawn", ""],
            ["queen", "bishop"]
        ]'''

        with self.assertRaises(ValueError):
            line_finder.parse_board(board_json)

    def test_single_trap_reachability(self):
        """Test line calculation for a board with a single trap."""
        board_json = '''[
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "trap", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"]
        ]'''

        board = line_finder.parse_board(board_json)
        trap_lines, inaccessible_lines = line_finder.find_trap_lines(board)

        # Should have one trap
        self.assertEqual(len(trap_lines), 1)

        # Should have lines for the trap
        trap_id = list(trap_lines.keys())[0]
        self.assertIn(trap_id, trap_lines)
        self.assertGreater(len(trap_lines[trap_id]), 0)

    def test_inaccessible_lines_detection(self):
        """Test detection of inaccessible full lines."""
        board_json = '''[
            ["trap", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"]
        ]'''

        board = line_finder.parse_board(board_json)
        trap_lines, inaccessible_lines = line_finder.find_trap_lines(board)

        # The trap is in (0,0) and reaches to the right and down
        # The top row, left column, and main diagonal should be inaccessible
        self.assertGreater(len(inaccessible_lines), 0)

    def test_output_format(self):
        """Test that stdout has the correct format."""
        board_json = '''[
            ["trap", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"]
        ]'''

        # Mock sys.argv to test main function
        import sys
        old_argv = sys.argv
        try:
            sys.argv = ["line_finder.py", board_json]
            # Redirect stdout to capture output
            f = io.StringIO()
            with redirect_stdout(f):
                line_finder.main()
            output = f.getvalue()

            # Should contain the expected sections
            self.assertIn("Trap Reachability:", output)
            self.assertIn("Inaccessible Full Lines:", output)
        finally:
            sys.argv = old_argv

    def test_custom_piece_types_and_trap(self):
        """Test that custom piece types like 'blue_pawn' are accepted while traps still work."""
        board_json = '''[
            ["trap", "blue_pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"],
            ["pawn", "knight", "queen", "bishop", "rook", "king", "pawn", "pawn"]
        ]'''

        # This should not raise a ValueError
        board = line_finder.parse_board(board_json)

        # Verify that the board contains the expected strings
        self.assertEqual(board[0][0], "trap")
        self.assertEqual(board[0][1], "blue_pawn")

        # Verify that trap lines can still be found and computed
        trap_lines, inaccessible_lines = line_finder.find_trap_lines(board)

        # Should have one trap
        self.assertEqual(len(trap_lines), 1)

        # Should have lines for the trap
        trap_id = list(trap_lines.keys())[0]
        self.assertIn(trap_id, trap_lines)
        self.assertGreater(len(trap_lines[trap_id]), 0)

if __name__ == "__main__":
    unittest.main()