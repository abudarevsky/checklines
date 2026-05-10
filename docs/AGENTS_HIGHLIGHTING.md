# Highlighting

Highlights are part of gameplay communication.

Current working approach:

- Add `ColorRect` highlights to `PiecesContainer`
- Use highlights for valid moves
- Clear highlights on deselection or after move

Keep this approach unless there is a strong reason to change it.

Possible highlight types:

- valid move cells
- selected piece
- completed line preview
- incomplete 4-of-5 line hint, optional

