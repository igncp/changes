Replace used libraries by other ones. Each replacement is saved in a different diff.

Notes:
- The `got` library uses a promises-based pattern that doesn't look right as the general pattern is to use callbacks (except for loadAsync)
