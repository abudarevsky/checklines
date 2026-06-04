"""Unit tests for line_finder.py."""

import unittest
import json
import subprocess
import sys
import os

# Path to the script
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
SCRIPT_PATH = os.path.join(PROJECT_ROOT, "..", "line_finder.py")

class TestLineFinder(unittest.TestCase):
    """Test the functionality of line_finder.py."""

    def test_parse_board_valid(self):
        """Valid board JSON should parse correctly."""
        board = [
            ["trap","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"],
            ["pawn","pawn","pawn","pawn","pawn","pawn","pawn","pawn"]
        ]
        board_json = json.dumps(board)
        import line_finder
        parsed = line_finder.parse_board(board_json)
        self.assertEqual(len(parsed), 8)
        self.assertEqual(len(parsed[0]), 8)
        self.assertEqual(parsed[0][0], "trap")

    def test_parse_board_invalid(self):
        """Invalid board size should raise ValueError."""
        import line_finder
        board_json = "[[\"trap\",\"pawn\"],[\"pawn\",\"pawn\"]]"
        with self.assertRaises(ValueError) as cm:
            line_finder.parse_board(board_json)
        self.assertIn("Board must be 8x8", str(cm.exception))

    def test_trap_reachability(self):
        """A trap in a dense 8x8 board should only have short lines (length 2)."""
        import line_finder
        dense_board = [["trap"] + ["pawn"]*7 for _ in range(8)]
        board_json = json.dumps(dense_board)
        board = line_finder.parse_board(board_json)
        trap_lines, inaccessible = line_finder.find_trap_lines(board)
        self.assertIn("trap_0", trap_lines)
        # Must have at least one line of length 2
        self.assertTrue(any(len(line) == 2 for line in trap_lines["trap_0"]))
        # Must NOT have any full 8‑cell lines
        for line in trap_lines["trap_0"]:
            self.assertNotEqual(line, [(0, c) for c in range(8)], "Should not have a full row")
            self.assertNotEqual(line, [(r, 0) for r in range(8)], "Should not have a full column")
            self.assertNotEqual(line, [(i, i) for i in range(8)], "Should not have full main diagonal")
            self.assertNotEqual(line, [(i, 7-i) for i in range(8)], "Should not have full anti‑diagonal")

    def test_output_format(self):
        """Run the script as a subprocess and verify the formatted output."""
        dense_board = [["trap"] + ["pawn"]*7 for _ in range(8)]
        board_json = json.dumps(dense_board)
        result = subprocess.run(
            [sys.executable, os.path.join("..", "line_finder.py"), board_json],
            cwd=os.path.dirname(__file__),
            capture_output=True,
            text=True,
            check=True,
        )
        output = result.stdout
        # Ensure the two main sections exist exactly once
        self.assertIn("Trap Reachability:", output)
        self.assertIn("Inaccessible Full Lines:", output)
        self.assertEqual(output.count("Trap Reachability:"), 1)
        # Ensure a trap identifier is printed
        self.assertRegex(output, r"trap_[0-9]+: \d+ lines")
        # The main diagonal (0,0)-(7,7) should be reachable for the corner trap, so it must NOT appear in the inaccessible section.
        # Extract lines after the Inaccessible section and verify the diagonal is absent.
        after = output.split("Inaccessible Full Lines:")[1]
        diagonal_line = " ".join([f"({i},{i})" for i in range(8)])
        self.assertNotIn(diagonal_line, after, "Main diagonal should be reachable, not listed as inaccessible")

if __name__ == "__main__":
    unittest.main()