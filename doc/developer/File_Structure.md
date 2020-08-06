# File Structure

The notes are stored in plain-text with a filename of the pattern `yyyy-mm-dd_hh-mm-ss` or `yyyy-mm-dd_hh-mm-ss_n` which is basically a timestamp of the note's creation (with `n` being an incrementing number in case a file with that name alredy exists, which is highly unlikely). The filename "stores" the creation date of the note and is used when sorting the notes and displaying details.

The extension of the file is `.txt`.

## Contents

The first line (ends with `\n`) of the file contains the title of the note. Anything after that is considered content and is put in the body of the note.

## Other details

Details other than the title and creation date displayed in the Details Dialog are retrieved from the file itself (using dart's file functions).

---

**Related:**

- [Folder Structure](Folder_Structure.md)