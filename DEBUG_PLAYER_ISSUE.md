# Debug: Players Not Saving Issue

## What I Added

1. **Error handling** in the add player dialog
   - Will now show a SnackBar with the actual error if insert fails
   
2. **Success message** when player is added
   - Shows "Added [Player Name]" if successful

3. **Debug button** in Teams screen
   - 🐛 Bug icon in the app bar
   - Tap it to print database contents to console

## How to Debug

### Step 1: Run the app and watch the console

```bash
flutter run
```

Keep the terminal visible so you can see output.

### Step 2: Try to add a player

1. Make sure team is selected (✅ checkmark)
2. Go to Roster screen
3. Tap "+ Add Player"
4. Enter name: "Test Player"
5. Enter number: "99"
6. Tap "Add"

### Step 3: Check what happens

**If successful:**
- Dialog closes
- SnackBar shows "Added Test Player"
- Player appears in list

**If error:**
- SnackBar shows "Error: [message]"
- Look at the error message!

### Step 4: Check database state

1. Go to Teams screen (tap back or "Change")
2. Tap the 🐛 (bug) icon in top right
3. Look at your terminal/console output
4. You should see:

```
=== DATABASE DEBUG ===
Teams count: 1
  - [Your Team Name] (id: xxx-xxx-xxx)
    Players: 1
      - Test Player #99 (order: 1)
=== END DEBUG ===
```

## What to Look For

### Scenario A: Error message appears
**SnackBar shows**: "Error: [something]"

Copy the entire error message and share it. This will tell us exactly what's wrong.

### Scenario B: Success message but no player shows
**SnackBar shows**: "Added Test Player"
**But**: Player doesn't appear in list

This means:
- Insert succeeded
- Problem is with the UI update/provider

Tap 🐛 to check if player is in database.

### Scenario C: Nothing happens
**No SnackBar at all**

This means validation failed or dialog didn't trigger. Check:
- Did you enter both name and number?
- Is number between 0-99?

### Scenario D: Player appears briefly then disappears
This would indicate a provider/stream issue.

## Quick Tests

### Test 1: Use seed data
```bash
1. Go to Teams screen
2. Tap 🧪 (flask icon)
3. This should create 3 teams with players
4. Tap 🐛 to verify in console
5. Select "Wildcats"
6. Go to Game Day - players should show
```

If seed data works but manual add doesn't, it's an insert issue.

### Test 2: Hot restart
After trying to add a player:
```bash
# In the terminal where flutter run is running:
# Press 'R' (capital R) for hot restart
```

If player appears after restart, it's a UI refresh issue.

### Test 3: Check console for SQLite errors
Look for any lines containing:
- "SQL"
- "drift"
- "database"
- "constraint"
- "foreign key"

## Most Likely Issues

### Issue 1: UUID Import Problem
The `Uuid().v4()` might not be generating valid IDs.

**Check**: Look for error like "Invalid UUID format"

### Issue 2: Foreign Key Constraint
Team ID mismatch between selected team and insert.

**Check**: Look for error like "FOREIGN KEY constraint failed"

### Issue 3: Provider Not Refreshing
Data saves but UI doesn't update.

**Check**: Run 🐛 debug - if player is there, it's a UI issue

### Issue 4: Drift Companion Issue
The `PlayersCompanion.insert()` parameters might be wrong.

**Check**: Look for error about "required parameter" or "type mismatch"

## What to Share

When you run the debug:

1. **Any error messages** from SnackBar
2. **Console output** after tapping 🐛
3. **What you see** in the UI vs what 🐛 shows in console

## Expected Output

**Console after adding 1 player should show:**
```
=== DATABASE DEBUG ===
Teams count: 1
  - My Team (id: 12345-abc-...)
    Players: 1
      - Test Player #99 (order: 1)
=== END DEBUG ===
```

**If you see Players: 0**
→ Insert is failing silently or wrong team ID

**If you see Players: 1 but UI shows empty**
→ Provider/stream not updating

---

## Next Steps

Run the app, try adding a player, and let me know:
1. What SnackBar message you see (if any)
2. What 🐛 debug shows in console
3. Any errors in the terminal

This will tell us exactly where the problem is!
