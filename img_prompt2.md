You are classifying ONE chess-board square.

Return ONLY JSON:
{
  "occupied": true or false,
  "piece": "king" | "queen" | "rook" | "bishop" | "knight" | "pawn" | "trap" |null,
  "color": "red" | "blue" | "green" | "yellow" | "trap" | null
}

Rules:
- If unsure, use occupied=false.
- Do not infer pieces from nearby squares.
- Do not describe the image.
- TRAP = none blue,red,yelow or green icon, colored corner markers.
