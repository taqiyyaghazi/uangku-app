# Uangku - Epic Breakdown

**Date:** 2026-03-04
**Project Level:** 1 (Focused Feature Set)
**Status:** Feature Complete (MVP) / Expanding Phase

---

## Overview

This document decomposes the requirements for **Uangku** into logical phases of development. Each epic delivers a functional part of the application, moving from the core data foundation to the "Daily Breath" logic, and finally to long-term portfolio visualization and post-launch refinements.

---

## Epic 1: Foundation & Wallet Core

**Goal:** Establish the offline-first data layer and the primary navigation structure.
**Success Criteria:** User can open the app and manage multiple wallets (Create/Update/Delete) with local persistence.

### Stories in Epic 1:

- **Story 1.1: Project Setup & Database Schema** (3 pts)
- **Story 1.2: Wallet Management UI (The Unified Grid)** (3 pts)

---

## Epic 2: The "Daily Breath" Budgeting System

**Goal:** Implement the core "magic" of the app—dynamic daily budgeting.
**Success Criteria:** Every expense entry triggers a "gentle adjustment" to the remaining daily allowance for the month.

### Stories in Epic 2:

- **Story 2.1: Unified Transaction Entry (Quick-Log)** (2 pts)
- **Story 2.2: Dynamic Budget Engine** (5 pts)

---

## Epic 3: Portfolio & Growth Visualization

**Goal:** Add the "Strategy Zone" for tracking long-term net worth.
**Success Criteria:** User can see a trend line of their total assets across all wallets over several months.

### Stories in Epic 3:

- **Story 3.1: Manual Asset Value Entry** (2 pts)
- **Story 3.2: Investment Trends & Alocations (Charts)** (3 pts)

---

## Epic 4: Post-Launch Refinements

**Goal:** Enhance the usability, flexibility, and historical tracking of the system.
**Success Criteria:** User can manage a full history of transactions, customize categories, and perform internal transfers.

### Stories in Epic 4:

- **Story 4.1: Budget Configuration & Storage** (2 pts)
- **Story 4.2: Recent Transactions Feed** (2 pts)
- **Story 4.3: Transaction Management** (3 pts)
- **Story 4.4: Full History and Archive Access** (2 pts)
- **Story 4.5: Transaction Memo and Contextual Notes** (1 pt)
- **Story 4.6: Custom Category Management** (3 pts)
- **Story 4.7: Transaction Backdating and Date Selection** (2 pts)
- **Story 4.8: Internal Wallet Transfer Logic** (3 pts)

---

## Epic 5: Insights & Analytics

**Goal:** Provide visual tools to better understand spending behavior and financial health.
**Success Criteria:** User can see their spending distribution by category and daily trends in a dedicated "Insights" section.

### Stories in Epic 5:

- **Story 5.1: The Spending Pie (Category Distribution)** (3 pts)
- **Story 5.2: Daily Spending Trend (Line Chart)** (3 pts)
- **Story 5.3: Monthly Comparison (Performance Review)** (2 pts)

---

## Epic 6: Deployment & Versioning

**Goal:** Finalize the application identity and prepare for stable distribution.
**Success Criteria:** The app is branded as "Uangku" with its own assets, and a versioning strategy is in place.

### Stories in Epic 6:

- **Story 6.1: Branding & Identity (Identity Pack)** (2 pts)
- **Story 6.2: Versioning & Update Strategy** (1 pt)

---

## Epic 7: Data Integrity & Portability

**Goal:** Ensure users have accurate, flexible, and exportable financial data, alongside application stability monitoring.
**Success Criteria:** Users can backdate transactions, filter history by wallet, export data to CSV, and the app monitors crashes and feature usage via Firebase.

### Stories in Epic 7:

- **Story 7.1: Edit Transaction Date (Backdating Adjustment)** (2 pts)
- **Story 7.2: Wallet-Based History Filter** (3 pts)
- **Story 7.3: Export Transactions to CSV** (5 pts)
- **Story 7.4: Stability & Usage Monitoring (Firebase SDK)** (3 pts)

---

## Epic 8: Cloud Synchronization

**Goal:** Provide secure data backup and enable cross-device synchronization through Google account integration.
**Success Criteria:** User can authenticate with Google, local data is mirrored to Firestore in real-time, and data is successfully restored on new devices.

### Stories in Epic 8:

- **Story 8.1: Secure Login with Google (Firebase Auth)** (3 pts)
- **Story 8.2: Database Mapping to Firestore (Cloud Sync)** (8 pts)
- **Story 8.2.1: Cloud Sync for Budgets & Investments** (3 pts)
- **Story 8.3: Instant Sync & Recovery (Data Restoration)** (5 pts)
- **Story 8.4: Flutter Flavors Setup (Environment Separation)** (5 pts)

---

## Epic 9: Power User Experience (UX Refactor)

**Goal:** Refactor existing features for enhanced usability and speed for power users.
**Success Criteria:** User can view wallets compactly, easily search and pick categories/wallets, and quickly add entries from context-heavy screens.

### Stories in Epic 9:

- **Story 9.1: Dashboard Wallet Layout Refactor (Carousel View)** (3 pts)
- **Story 9.2: Searchable Picker for Categories & Wallets** (5 pts)
- Story 9.3: Quick Entry from History Screen (2 pts)

---

## Epic 10: Advanced Discovery & Deep Filtering

**Goal:** Refine how users find and filter their data for better financial control.
**Success Criteria:** Users can manage all wallets from a central hub and filter their transaction history by specific types like "Investment".

### Stories in Epic 10:

- **Story 10.1: Wallet Management Hub & Quick Search** (3 pts)
- **Story 10.2: Core Transaction Type Filter** (2 pts)

---

## Implementation Sequence

1.  **Epic 1** (Foundation & UI Shell)
2.  **Epic 2** (The Core Budget Logic)
3.  **Epic 3** (Investment Visualization)
4.  **Epic 4** (Advanced Transaction Features)
5.  **Epic 5** (Financial Insights)
6.  **Epic 6** (Identity & Polish)
7.  **Epic 7** (Data Integrity & Portability)
8.  **Epic 8** (Cloud Synchronization)
9.  **Epic 9** (Power User Experience)
10. **Epic 10** (Advanced Discovery & Filtering)

**Total Story Points:** 99 Points
**Total Stories:** 33 Stories
**Estimated Timeline:** 6-8 Sprints (approx. 2-2.5 months)
