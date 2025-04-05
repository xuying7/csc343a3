-- schema.ddl
DROP SCHEMA IF EXISTS A3GLG CASCADE;
CREATE SCHEMA A3GLG;
SET SEARCH_PATH TO A3GLG;

/*
  Assumptions:
    - Integer IDs (SERIAL) are used for all entities.
    - Enumerated values (e.g., category, condition) are enforced via CHECK constraints.
    - A partial index ensures only one lead per event (OrganizingCommittee).
*/

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