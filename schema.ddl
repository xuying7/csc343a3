-- schema.ddl
DROP SCHEMA IF EXISTS A3GLG CASCADE;
CREATE SCHEMA A3GLG;
SET SEARCH_PATH TO A3GLG;

/*
================================================================================
Documentation of Choices & Assumptions
================================================================================

**Could not:**
The following domain constraints could not be enforced without triggers/assertions:
1. **Overlapping Participation:** 
   - "No member can participate in two game sessions at the same time." 
   - Requires checking temporal overlaps between sessions, which DDL cannot enforce.
2. **Executive Facilitation Limits:** 
   - "No exec member should facilitate two game sessions at once."
   - Requires tracking session timestamps (not stored) and checking overlaps.
3. **Damaged Game Usage:** 
   - "Damaged games cannot be played." 
   - Requires validating `Copies.condition` when inserting into `GameSessions`, which needs a trigger.
4. **Exactly One Lead per Committee:** 
   - The partial index ensures *at most* one lead per event but does not enforce *at least* one lead. Ensuring a committee always has exactly one lead requires a trigger.

**Did not:**
- **Enumerated Value Ranges:** 
  - We did not explicitly use PostgreSQL `ENUM` types for fields like `category` or `condition`, opting for `CHECK` constraints instead. This avoids schema rigidity while still enforcing valid values.
- **Facilitator Participation:** 
  - The domain allows facilitators to play in the same game they facilitate. We did not add a constraint to explicitly permit this, as it is allowed by omission in the schema.

**Extra constraints:**
1. **Unique Email:** 
   - Added `UNIQUE` to `Members.email` to prevent duplicate registrations, though not explicitly required by the domain.
2. **Player Limits:** 
   - `CHECK (min_players <= max_players)` in `BoardGames` ensures logical player ranges.
3. **Valid Enumerations:** 
   - `CHECK` constraints on `level_of_study`, `category`, and `condition` enforce domain-specific valid values.
4. **Partial Index for Lead Uniqueness:** 
   - `CREATE UNIQUE INDEX ... WHERE is_lead` ensures no event has multiple leads.

**Assumptions:**
1. **Temporal Scope:** 
   - Events are assumed to run for their entire `event_date`; overlapping sessions are prevented by not storing start/end times.
2. **Data Integrity:** 
   - Free-text fields (e.g., `publisher`) are not further validated, trusting input accuracy.
3. **Copy Tracking:** 
   - Multiple copies of the same game are tracked via `Copies`, but no attempt is made to distinguish identical copies beyond `copy_id`.
4. **Event Recurrence:** 
   - Events with the same `event_name` are considered distinct if they have different `event_date`/`location`, even if part of a recurring series.
5. **Serial IDs:** 
   - All `SERIAL` keys (e.g., `member_id`, `game_id`) are assumed to be sufficient for unique identification.


-------------------------------------------------------------------------------
-- Table: Members
-------------------------------------------------------------------------------
CREATE TABLE Members (
    member_id       SERIAL PRIMARY KEY,
    member_name     VARCHAR(100) NOT NULL,
    email           VARCHAR(200) NOT NULL UNIQUE,
    level_of_study  VARCHAR(20) NOT NULL 
        CHECK (level_of_study IN ('Undergraduate', 'Graduate', 'Alumni'))
);

COMMENT ON TABLE Members IS
'Stores all GLG members. Each member has a unique email and study level.';

-------------------------------------------------------------------------------
-- Table: Execs
-------------------------------------------------------------------------------
CREATE TABLE Execs (
    member_id    INTEGER PRIMARY KEY,
    role         VARCHAR(50) NOT NULL,
    date_assumed DATE NOT NULL,
    CONSTRAINT fk_exec_member 
        FOREIGN KEY (member_id) 
        REFERENCES Members (member_id)
        ON DELETE CASCADE
);

COMMENT ON TABLE Execs IS
'Executive members with additional roles and start dates. Subset of Members.';

-------------------------------------------------------------------------------
-- Table: BoardGames
-------------------------------------------------------------------------------
CREATE TABLE BoardGames (
    game_id      SERIAL PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    category     VARCHAR(30) NOT NULL 
        CHECK (category IN ('Strategy', 'Party', 'Deck-building', 
                            'Role-playing', 'Social-deduction')),
    min_players  INT NOT NULL,
    max_players  INT NOT NULL CHECK (min_players <= max_players),
    publisher    VARCHAR(100),
    release_year INT
);

COMMENT ON TABLE BoardGames IS
'Board game metadata. Includes player limits and category constraints.';

-------------------------------------------------------------------------------
-- Table: Copies
-------------------------------------------------------------------------------
CREATE TABLE Copies (
    copy_id          SERIAL PRIMARY KEY,
    game_id          INTEGER NOT NULL,
    acquisition_date DATE,
    condition        VARCHAR(20) NOT NULL 
        CHECK (condition IN ('New', 'Lightly-used', 'Worn', 
                             'Incomplete', 'Damaged')),
    CONSTRAINT fk_copy_game
        FOREIGN KEY (game_id)
        REFERENCES BoardGames (game_id)
);

COMMENT ON TABLE Copies IS
'Physical copies of games. Condition enforced to valid states.';

-------------------------------------------------------------------------------
-- Table: Events
-------------------------------------------------------------------------------
CREATE TABLE Events (
    event_id    SERIAL PRIMARY KEY,
    event_name  VARCHAR(100) NOT NULL,
    location    VARCHAR(100) NOT NULL,
    event_date  DATE NOT NULL
);

COMMENT ON TABLE Events IS
'Events organized by GLG. Same name can have multiple occurrences.';

-------------------------------------------------------------------------------
-- Table: OrganizingCommittee
-------------------------------------------------------------------------------
CREATE TABLE OrganizingCommittee (
    event_id  INTEGER NOT NULL,
    exec_id   INTEGER NOT NULL,
    is_lead   BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (event_id, exec_id),
    CONSTRAINT fk_orgc_event
        FOREIGN KEY (event_id) 
        REFERENCES Events (event_id),
    CONSTRAINT fk_orgc_exec
        FOREIGN KEY (exec_id)
        REFERENCES Execs (member_id)
);

-- Enforce one lead per event
CREATE UNIQUE INDEX one_lead_per_event 
    ON OrganizingCommittee (event_id) 
    WHERE is_lead;

COMMENT ON TABLE OrganizingCommittee IS
'Event organizing teams. Only one lead allowed per event (partial index).';

-------------------------------------------------------------------------------
-- Table: GameSessions
-------------------------------------------------------------------------------
CREATE TABLE GameSessions (
    session_id     SERIAL PRIMARY KEY,
    event_id       INTEGER NOT NULL,
    copy_id        INTEGER NOT NULL,
    facilitated_by INTEGER NOT NULL,
    CONSTRAINT fk_sess_event
        FOREIGN KEY (event_id)
        REFERENCES Events(event_id),
    CONSTRAINT fk_sess_copy
        FOREIGN KEY (copy_id)
        REFERENCES Copies(copy_id),
    CONSTRAINT fk_sess_exec
        FOREIGN KEY (facilitated_by)
        REFERENCES Execs(member_id)
);

COMMENT ON TABLE GameSessions IS
'Game sessions at events. Each facilitated by an exec using a specific copy.';

-------------------------------------------------------------------------------
-- Table: SessionParticipants
-------------------------------------------------------------------------------
CREATE TABLE SessionParticipants (
    session_id INTEGER NOT NULL,
    member_id  INTEGER NOT NULL,
    PRIMARY KEY (session_id, member_id),
    CONSTRAINT fk_part_sess
        FOREIGN KEY (session_id)
        REFERENCES GameSessions(session_id),
    CONSTRAINT fk_part_member
        FOREIGN KEY (member_id)
        REFERENCES Members(member_id)
);

COMMENT ON TABLE SessionParticipants IS
'Members participating in game sessions. Composite primary key.';