# Attack Rule (Board Manipulation)

A piece may capture another piece by moving onto its cell if:

- the target piece is of a different color  
- the movement follows the attacking piece's movement rules  

Result:
- the attacking piece replaces the target piece  
- the target piece is removed  

Restrictions:
- same-color pieces cannot be captured  
- Kings cannot be captured  

Attacks do not generate score and do not count as line completion.  
After an attack, line detection is evaluated normally.