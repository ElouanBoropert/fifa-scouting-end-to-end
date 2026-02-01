# Insights (FIFA Scouting & Valuation)

This project models a scouting/valuation dataset end-to-end (cleaning → PostgreSQL star-ish model → BI views → Power BI).
Current warehouse load contains **17,954 players**, **15 position codes**, and **29,534 player-position links** (many players can cover multiple roles).

## Insight 1 — Upside-first shortlists surface “high gap, low cost” profiles
The shortlist logic prioritizes players with a large **potential_gap** while applying a cost penalty (value).
In practice, top-ranked profiles by position tend to combine:
- solid current overall (not necessarily elite),
- strong upside (high potential_gap),
- manageable transfer value.

Why it matters:
- This produces actionable “shopping lists” for recruitment teams targeting development value rather than only finished stars.

How to validate in the dashboard:
- Use the **Shortlist** page, filter a single position, sort by **scouting_score**, and compare **potential_gap** vs **value_euro**.

## Insight 2 — Many players are multi-position: role flexibility is a real scouting lever
There are **29,534** player-position associations for **17,954** players (~1.6 positions/player on average).
Why it matters:
- Versatile players reduce squad risk (injuries/rotation) and may be undervalued if they can cover multiple tactical needs.

How to validate:
- In **Shortlist**, change position filters and observe players re-appearing across adjacent roles (e.g., CM/CDM/CAM, ST/CF/RW).

## Insight 3 — Value and wages can be normalized to reveal efficiency outliers
Two engineered metrics help compare players more fairly:
- **value_per_overall** (value_euro / overall_rating)
- **wage_per_overall** (wage_euro / overall_rating)

Why it matters:
- High overall does not always mean “efficient” — some players are expensive for their level.
- These ratios help flag “overpriced” players and identify bargain contracts.

How to validate:
- In **Overview** (scatter), plot **overall_rating** vs **value_euro**, then use tooltips for value_per_overall.
- In **Shortlist**, sort ascending on value_per_overall to spot value-for-money targets.

## Insight 4 — Percentiles by position improve interpretation beyond raw attributes
Raw attributes (e.g., finishing, passing, interceptions) are role-dependent.
Percentiles computed within a position group make comparisons meaningful:
- A CDM with “70 passing” may be elite relative to CDMs, while “70 passing” for CAMs is average.

Why it matters:
- Percentiles support explainability: “top 10% interceptions among CDMs” is clearer than a raw number.

How to validate:
- In **Player Profile**, compare the player’s position percentiles (finishing/passing/dribbling/interceptions/tackles) to confirm fit for the intended role.