# Removal Rules (Scoring)

The primary way to score is by forming and removing valuable formations.

Supported target formations:

1. Color Line  
   - 5 or more pieces of the same color  
   - piece type does not matter  
   - awards base score  

2. Type Line  
   - 5 or more pieces of the same chess type  
   - color does not matter  
   - awards stronger score than a color line

3. Royal Line
   - 4 same-type pieces plus the only King on the board
   - represents the signature high-value formation of Royal Lines

If a line satisfies both conditions (same color and same type), apply a combo bonus.

Only successful scoring formations generate positive line score. Capture or sacrifice actions may reduce score separately when they consume valuable pieces.
