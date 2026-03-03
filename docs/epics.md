# Uangku - Epic Breakdown

**Date:** 2026-03-02
**Project Level:** 1 (Focused Feature Set)
**Status:** Planning Complete

---

## Overview

This document decomposes the requirements for **Uangku** into three logical phases of development. Each epic delivers a functional part of the application, moving from the core data foundation to the "Daily Breath" logic, and finally to long-term portfolio visualization.

---

## Epic 1: Foundation & Wallet Core

**Goal:** Establish the offline-first data layer and the primary navigation structure.
**Success Criteria:** User can open the app and manage multiple wallets (Create/Update/Delete) with local persistence.

### Stories in Epic 1:

* **Story 1.1: Project Setup & Database Schema** (3 pts)
* Initialize Flutter, Riverpod, and define Drift tables for Wallets and Transactions.


* **Story 1.2: Wallet Management UI (The Unified Grid)** (3 pts)
* Build the dashboard top-section showing all wallets in a grid with Teal "Ocean Flow" styling.



---

## Epic 2: The "Daily Breath" Budgeting System

**Goal:** Implement the core "magic" of the app—dynamic daily budgeting.
**Success Criteria:** Every expense entry triggers a "gentle adjustment" to the remaining daily allowance for the month.

### Stories in Epic 2:

* **Story 2.1: Unified Transaction Entry (Quick-Log)** (2 pts)
* Create the Floating Action Button and the high-speed entry form (Numpad auto-focus).


* **Story 2.2: Dynamic Budget Engine** (5 pts)
* Implement the logic: `(Sisa Budget / Sisa Hari)`. Handle the overspend calculation and state updates across the app.



---

## Epic 3: Portfolio & Growth Visualization

**Goal:** Add the "Strategy Zone" for tracking long-term net worth.
**Success Criteria:** User can see a trend line of their total assets across all wallets over several months.

### Stories in Epic 3:

* **Story 3.1: Manual Asset Value Entry** (2 pts)
* Build a simple form to update the current value of "Investment" type wallets.


* **Story 3.2: Investment Trends & Alocations (Charts)** (3 pts)
* Integrate `fl_chart` to display the Line Chart (Growth) and Donut Chart (Allocation).



---

## Implementation Sequence

1. **Story 1.1** (Foundation)
2. **Story 1.2** (UI Shell)
3. **Story 2.1** (Data Input)
4. **Story 2.2** (The "Coach" Logic)
5. **Story 3.1** (Investment Input)
6. **Story 3.2** (Visual Analytics)

**Total Story Points:** 18 Points
**Estimated Timeline:** 2-3 Sprints (approx. 2-3 weeks)
