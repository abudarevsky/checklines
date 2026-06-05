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

When a selected piece clicks an enemy king that it could otherwise attack by movement geometry:
- show that king as an attack target while the attacker is selected, using a small crossed/blocked marker instead of the attacker's piece miniature
- do not move the piece
- do not select the king
- play the one-second king rebuff effect from king to attacker
- tremble the attacker during the effect
- show the HUD score event `"The king is untouchable!"` with a `-2` penalty

Attacks do not generate score and do not count as line completion.  
After an attack, line detection is evaluated normally.
