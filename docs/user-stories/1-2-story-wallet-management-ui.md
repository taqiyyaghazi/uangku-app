# 📄 Story 1.2: Wallet Management UI (The Unified Grid)

**Status:** Ready | **Epic:** 1 | **Points:** 3

* **User Story:** As a user, I want to see all my wallets in a clean grid at the top of my dashboard so that I can instantly see my total assets.
* **Acceptance Criteria:**
1. **AC #1:** Home screen displays a grid (2 columns) of "Wallet Cards."
2. **AC #2:** Each card shows the Wallet Name, Balance (formatted), and an Icon.
3. **AC #3:** Cards must use the **Ocean Flow** palette (Teal borders/text on Soft Grey).
4. **AC #4:** Tapping a card opens an "Edit Wallet" modal to adjust name or initial balance.


* **Technical Notes:**
* Use `SliverGrid` for a smooth scrolling dashboard experience.
* Consume the `walletsProvider` (Riverpod) which streams from the Drift database.
* Reference `ux-design-specification.md` for card styling.



---

### 📄 Story 2.1: Unified Transaction Entry (Quick-Log)

**Status:** Ready | **Epic:** 2 | **Points:** 2

* **User Story:** As a user, I want a single, prominent button to record money movements so that I can log transactions in under 3 seconds.
* **Acceptance Criteria:**
1. **AC #1:** Display a Teal Floating Action Button (FAB) on the Dashboard.
2. **AC #2:** Tapping FAB opens a bottom sheet with a custom Number Pad.
3. **AC #3:** Form must include toggles for: **Income**, **Expense**, and **Transfer**.
4. **AC #4:** User must be able to select the "Source Wallet" and "Category."


* **Technical Notes:**
* Implement a custom `NumPad` widget to avoid the default system keyboard lag.
* On Save, trigger a Drift transaction that updates the `Transactions` table and the `Wallets.balance` simultaneously.



---

### 📄 Story 2.2: Dynamic Budget Engine

**Status:** Ready | **Epic:** 2 | **Points:** 5 (CRITICAL)

* **User Story:** As a user, I want my daily budget to adjust automatically when I overspend so that I stay on track for the month without feeling stressed.
* **Acceptance Criteria:**
1. **AC #1:** Calculate `daily_allowance` using: `(Monthly_Limit - Total_Spent) / Days_Remaining`.
2. **AC #2:** Home screen displays a "Daily Breath" progress bar showing the remaining allowance for *today*.
3. **AC #3:** If a transaction exceeds today's limit, the bar turns **Amber**, and a "Gentle Adjustment" message appears.
4. **AC #4:** All logic must handle month-end resets automatically.


* **Technical Notes:**
* Create a `BudgetService` in Flutter to handle these calculations.
* Use `DateTime.daysInMonth` utility to calculate the `Days_Remaining` divisor.



---

### 📄 Story 3.1: Manual Asset Value Entry

**Status:** Ready | **Epic:** 3 | **Points:** 2

* **User Story:** As a user, I want to manually update the total value of my investment accounts so that I can track growth without logging every trade.
* **Acceptance Criteria:**
1. **AC #1:** "Investment" type wallets have an "Update Value" button.
2. **AC #2:** Saving a new value creates an entry in the `Investment_Snapshots` table.
3. **AC #3:** The Wallet balance updates to this new value immediately.


* **Technical Notes:**
* This is a "Snapshot" pattern. We store the value and the timestamp to generate the trend line in the next story.



---

### 📄 Story 3.2: Investment Trends & Allocations

**Status:** Ready | **Epic:** 3 | **Points:** 3

* **User Story:** As a user, I want to see my net worth growth and asset distribution in charts so that I can make better long-term decisions.
* **Acceptance Criteria:**
1. **AC #1:** Portfolio Tab displays a **Line Chart** of total assets over the last 6 months.
2. **AC #2:** Portfolio Tab displays a **Donut Chart** showing % of money in Cash vs. Bank vs. Investments.
3. **AC #3:** Charts must use Teal/Ocean Flow gradients.


* **Technical Notes:**
* Use `fl_chart` library.
* `LineChart` data comes from `Investment_Snapshots`.
* `PieChart` data comes from current `Wallets.balance` grouped by type.

