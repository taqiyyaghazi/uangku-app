# Uangku UX Design Specification

**Vibe:** Familiar & Accessible | **Theme:** Ocean Flow (Teal)

## 1. Core Experience: "The Daily Breath"

- **The Feeling:** "Empowered and in Control" through a supportive, non-judgmental interface.
- **Visual Mechanic:** A prominent progress bar or "breath meter" on the home screen showing today's available budget.
- **Gentle Adjustment:** When overspending happens, the UI uses smooth animations and Amber (not Red) highlights to show the adjusted budget for the following days.

## 2. Visual Foundation

- **Theme:** **Ocean Flow**.
- _Primary:_ Teal (#008080) - Represents flow and clarity.
- _Secondary:_ Soft Grey (#F5F5F5) - For background/containers.
- _Accent:_ Amber (#FFBF00) - For "Gentle Adjustment" warnings.

- **Typography:** Clean Sans-serif (Inter or Roboto) for high readability.

## 3. Layout Strategy

- **Dashboard (Layout B - Unified Grid):** All wallets are displayed as a grid of small, elegant cards showing name and balance at the top of the home screen.
- **Portfolio (Dedicated Tab):** A separate view for long-term growth.
- _Line Chart:_ Showing Net Worth trend over months.
- _Donut Chart:_ Showing Asset Allocation (e.g., 60% Bank, 40% Stocks).

## 4. Interaction Patterns

- **The "+" Button:** A large Floating Action Button (FAB) in Teal. Tapping it instantly opens a numpad.
- **Speed Principle:** Goal is < 3 seconds for any transaction entry.
- **Accessibility:** WCAG AA Target. Large touch targets (44x44px) and high-contrast text on Teal backgrounds.
- **Environment Visibility:** The Development build includes a Red "DEV" corner banner on the Dashboard to prevent accidental data entry into the testing environment.

---
