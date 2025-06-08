# 🎮 Habit Level Up - Keyboard Commands

This file contains all available keyboard shortcuts for testing and using the Habit Level Up app.

## ⌨️ Testing Commands

| Key | Command | Description |
|-----|---------|-------------|
| **N** | Next Day | Advance the simulated date by 1 day. Use this to test multi-day habit tracking, streak calculation, and level progression over time. |
| **R** | Reset Time | Reset the app back to real-time (current actual date). Use this when you're done testing with simulated dates. |
| **C** | Clear & Reset | Clear all habits from the app AND reset your level back to 1 with 0 XP. Complete reset for testing. |
| **D** | Debug Info | Show detailed debug information including current date, level stats, XP progress, and individual habit statistics. |

## 🎯 Usage Examples

### Testing Basic Functionality
1. Add a habit using the "Add New Habit" button
2. Complete it by clicking the circle icon (gains +1 XP)
3. Press **N** to advance to next day
4. Complete it again (streak should show 🔥 1)
5. Press **N** again and complete (streak should show 🔥 2)

### Testing Streak Breaking
1. Create a habit and complete it for a few days
2. Press **N** to advance a day
3. Press **N** again WITHOUT completing the habit
4. The streak should reset to 0

### Testing Habit Stacking
1. Create a basic habit like "Drink water"
2. Complete it (gets +1 XP)
3. Create a habit stack on "Drink water" called "Take vitamins"
4. Notice only "Drink water" shows initially
5. Press **N** to advance day, complete "Drink water" again
6. See purple notification "🔓 Unlocked: Take vitamins"
7. "Take vitamins" now appears with "Level 2 habit unlocked from Drink water"
8. Complete "Take vitamins" too
9. Name changes to "Drink water → Take vitamins 📚2"

### Testing Alarm Habit (Alarm + Window)
1. Create basic habit "Morning routine" 
2. Complete it to unlock alarm habits
3. Create alarm habit "Meditation ⏰07:00" (7 AM alarm, 30min window)
4. Use time simulation to test:
   - Before 7 AM: Shows "⏰ Alarm at 07:00"
   - After 7 AM: Shows "⏳ 30m 0s remaining" (countdown)
   - Complete within 30 min: Normal +1 XP
   - Miss 30 min window: "❌ Window expired"

### Testing Timed Session (Click Timer + Grace)
1. Create "Pomodoro ⏱️25m" timed session (25 minutes)
2. Shows "▶️ Click to start 25m session (+15m grace)" 
3. Click to start timer
4. Shows "⏱️ 24m 59s remaining" countdown
5. After 25 min: Shows "⏱️ 14m 59s grace period"
6. Complete within 40 min total (25 + 15): +1 XP
7. Miss 40 min total: Session expires (no penalty)

### Testing Time Window (Schedule)
1. Create "Work calls 🕐09:00-17:00" time window
2. Select Monday-Friday availability  
3. Test different times:
   - 8 AM: "🔒 Opens in 1h 0m"
   - 10 AM: "🟢 Available (7h 0m left)"
   - 6 PM: "🔒 Opens in 15h 0m" (next day)
   - Saturday: "🔒 Not available today"

### Testing Level Progression
1. Create habits and complete them to gain XP
2. Watch the progress bar fill up at the bottom
3. When you have enough XP, you'll level up with a purple notification
4. Click the progress bar to see detailed level information

### Reset Everything
- Press **C** to clear all habits and reset your level to start fresh

## 🎮 Leveling System

### XP Sources
- **+1 XP** - Complete any habit
- **+2 Bonus XP** - 3+ day streak
- **+5 Bonus XP** - 7+ day streak  
- **+15 Bonus XP** - 30+ day streak

## 📚 Habit Types

### Basic Habit
- Standard individual habit
- Tracks independently  
- Can be completed once per day

### Habit Stack  
- Builds on top of an existing habit
- **Hidden until base habit is completed today**
- Shows "📚" emoji next to name when unlocked
- Displays "Level X habit unlocked from [Base Habit]"
- Helps create habit chains (e.g., "Drink water" → "Take vitamins" → "Meditate")

### ⏰ Alarm Habit
- **Alarm-based habit with completion window**
- Set specific alarm time (e.g., 7:00 AM)
- Set completion window duration (e.g., 30 minutes after alarm)
- **Must complete within window or miss opportunity**
- Shows "⏰07:00" in name
- Hidden until base habit completed (like regular stacks)

### ⏱️ Timed Session  
- **Click-to-start timer habit**
- Set session duration (e.g., 25 minutes for Pomodoro)
- **Automatic 15-minute grace period** after session ends
- Click same area to start timer
- Shows "⏱️25m" in name
- Real-time countdown when active

### 🕐 Time Window
- **Only available during specific hours/days**
- Set start time and end time (end must be after start)
- Choose days of week (Monday, Tuesday, etc.)
- **Disabled outside window**
- Shows "🕐09:00-17:00" in name
- Green when available, locked when not

### Progressive Revelation System
1. **Only base habits show initially**
2. **Complete a base habit** → Stacked habit appears with 🔓 unlock message
3. **Complete both habits** → Display changes to "Base Habit → Stack Habit 📚2"
4. **Chain deeper** → Create habits stacked on stacked habits for longer chains

### Creating Habit Stacks
1. You must have at least one existing habit first
2. Select "Habit Stack" from the type dropdown 
3. Choose which habit to stack on from the dropdown
4. If no habits exist, "Habit Stack" will be crossed out and disabled
5. **New stacks won't appear until you complete their base habit**

### Level Requirements
- **Level 1 → 2**: 10 XP
- **Level 2 → 3**: 25 XP  
- **Level 3 → 4**: 45 XP
- And so on... (exponential growth)

### Progress Tracking
- Compact progress bar at bottom shows current level and XP progress
- Click the progress bar to open detailed level page
- Level page shows total XP, progress to next level, and planned features

## 🔍 Debug Information

Press **D** to see:
- Current simulated date
- Your level and total XP
- Progress percentage to next level
- List of all habits with detailed stats:
  - Current streak
  - Last completion date
  - Days since last completion
  - Whether completed today
  - Whether streak should be broken

## 💡 Tips

- **Multi-day testing**: Use **N** repeatedly to simulate weeks/months of usage
- **Level testing**: Complete many habits quickly to test level progression
- **Fresh start**: Use **C** when you want to test from scratch
- **Real usage**: Press **R** when you want to use the app normally (not simulated time)

---

*This command system is designed for development and testing. In production, only the progress bar and level page would be visible to users.*