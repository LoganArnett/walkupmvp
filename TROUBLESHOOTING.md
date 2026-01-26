# Troubleshooting Guide

## Cannot Add Players to Team

### Problem
You created a team but can't add players to the roster.

### Most Common Cause
**You need to SELECT a team first before the Roster screen will allow adding players.**

### Step-by-Step Fix

#### Method 1: Using Sample Data (Fastest)
```bash
flutter run

# 1. On Game Day screen, tap "Change" button
# 2. Tap the 🧪 (science flask) icon in the top right
# 3. This seeds 3 teams with 9 players each
# 4. Tap "Wildcats" to select it
# 5. Go back to Game Day
# 6. You should see 9 players!
# 7. Tap 👥 icon to manage roster
```

#### Method 2: Manual Setup (Proper Flow)
```bash
flutter run

# 1. On Game Day screen, note it says "No Team Selected"
# 2. Tap "Change" button
# 3. Tap "+ New Team" floating button
# 4. Enter team name (e.g., "My Team")
# 5. Tap "Create"
# 6. **IMPORTANT**: Tap on your newly created team in the list
#    - Team name should show ✅ checkmark
#    - This SELECTS the team as current
# 7. Screen automatically goes back to Game Day
# 8. Now tap 👥 (people) icon in top right
# 9. Tap "+ Add Player" floating button
# 10. Enter name and jersey number
# 11. Tap "Add"
# 12. Player appears in roster!
```

### Visual Confirmation

**Team is selected when:**
- ✅ Green checkmark appears next to team name in Teams screen
- Game Day screen shows team name instead of "No Team Selected"
- Roster screen shows "Add Player" button (not "No team selected")

**Team is NOT selected when:**
- No checkmark next to team name
- Game Day says "No Team Selected"
- Roster screen shows "No team selected" message

### Common Mistakes

❌ **Creating team but not tapping it to select**
- Creating a team doesn't automatically select it
- You must tap the team name to select it

❌ **Going directly to Roster screen**
- If no team is selected, Roster will say "No team selected"
- Must select team from Teams screen first

❌ **Not seeing the floating action button**
- Make sure a team is selected
- Scroll down if needed - FAB is at bottom right

### Quick Test

Run this to verify the flow:
```bash
flutter run

# Quick verification:
# 1. Game Day → Does it show team name or "No Team Selected"?
#    - If "No Team Selected" → Select a team first
#    - If team name shown → You're good to go
# 
# 2. Tap 👥 icon → Do you see "Add Player" button?
#    - If yes → You can add players
#    - If "No team selected" → Go back and select team
```

## Other Common Issues

### Issue: Players Added But Not Showing in Game Day

**Cause**: Team might have been changed after adding players

**Fix**:
1. Go to Teams screen (tap "Change")
2. Make sure correct team has ✅ checkmark
3. Go back to Game Day
4. Players should appear

### Issue: Cannot Tap "Add Player" Button

**Symptoms**: Button exists but does nothing when tapped

**Possible Causes**:
1. Dialog is opening behind current screen
2. Context issue

**Fix**:
```bash
# Try this:
flutter clean
flutter pub get
flutter run
```

### Issue: App Crashes When Adding Player

**Check**:
1. Run `flutter analyze` - any errors?
2. Check console for error messages
3. Try with sample data first (🧪 button)

### Issue: Team Appears Empty After Creating

**This is expected!**
- New teams start with 0 players
- Use "+ Add Player" to add players
- Or use 🧪 to seed sample data

## Debug Mode

To see what's happening:

1. **Check current team ID**:
   - In Game Day screen, team name shown = team is selected
   - "No Team Selected" = no team selected

2. **Verify data in database**:
   ```bash
   # After adding team/players:
   # Close app completely
   # Re-run: flutter run
   # Data should persist
   ```

3. **Reset everything**:
   ```bash
   # On iOS Simulator:
   # 1. Long press app icon
   # 2. Tap "Remove App"
   # 3. Tap "Delete App"
   # 4. flutter run (fresh start)
   ```

## Expected Behavior

### Creating and Using a Team

**Correct Flow:**
```
Game Day (No Team Selected)
  ↓ Tap "Change"
Teams Screen (Empty or has teams)
  ↓ Tap "+ New Team"
Dialog appears → Enter name → "Create"
  ↓ Dialog closes
Teams Screen shows new team
  ↓ TAP THE TEAM NAME ← CRITICAL STEP
Team gets ✅ checkmark
  ↓ Screen auto-closes
Game Day (Now shows team name)
  ↓ Tap 👥 icon
Roster Screen (Empty but has "+ Add Player" button)
  ↓ Tap "+ Add Player"
Dialog → Enter player info → "Add"
  ↓ Dialog closes
Roster Screen shows player!
  ↓ Go back
Game Day shows player in batting order!
```

### What Each Screen Should Show

**Game Day (No team selected):**
- "No Team Selected" text
- "Change" button
- Empty player list with "Add Players" button

**Game Day (Team selected):**
- Team name displayed
- "Change" button
- Player list OR empty state with "Add Players"

**Teams Screen:**
- List of teams
- ✅ next to currently selected team
- "+ New Team" floating button
- 🧪 icon for sample data

**Roster Screen (Team selected):**
- List of players OR "No players yet"
- "+ Add Player" floating button
- 🎵, ✏️, 🗑️ icons on each player

**Roster Screen (No team selected):**
- "No team selected" message
- No floating button

## Still Having Issues?

1. **Check Flutter version**:
   ```bash
   flutter --version
   # Should be 3.10.7 or higher
   ```

2. **Clean rebuild**:
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

3. **Check console output**:
   - Look for error messages
   - Share any red error text

4. **Try sample data**:
   - Use 🧪 button to seed data
   - If that works, manual flow should too

## Pro Tips

💡 **Use Sample Data for Testing**
- Fastest way to test audio features
- 3 teams, 9 players each, ready to go

💡 **One Team at a Time**
- Only one team can be "current" at a time
- Select different team to switch

💡 **Visual Indicators**
- ✅ = Current team
- Blue highlight = Selected player
- 🎵 = Audio assigned

💡 **Keyboard Shortcuts (when focused)**
- Hot reload: Press 'r' in terminal
- Hot restart: Press 'R' in terminal
- Quit: Press 'q' in terminal

---

**Most likely solution**: Make sure you're **tapping the team name to select it** after creating it! The ✅ checkmark is your confirmation that it's selected.
