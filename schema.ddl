DROP SCHEMA IF EXISTS A3GLG CASCADE;
CREATE SCHEMA A3GLG;
SET SEARCH_PATH TO A3GLG;

-- ============================================================================
-- schema.ddl
-- Part 1
-- ============================================================================

/*
  Could not enforce with simple DDL:
    - "No member can play in two sessions at the same time."
    - "No exec can facilitate two sessions at once or facilitate one while 
       playing a different session at the same time."
    - "An event’s organizing committee must have exactly one lead exec."
      (We only ensure is_lead is a boolean. Checking 'exactly one' would 
       require triggers or more advanced constraints.)
  
  Did not enforce (optional constraints):
    - enumerations for category or condition, but we could have used a CHECK.
    - multi-col constraints about min_players <= max_players.

  Extra constraints:
    - We made email UNIQUE for convenience.
  
  Assumptions:
    - We use integer IDs for everything (SERIAL in Postgres).
    - We allow any text for 'category', 'condition', etc., trusting the data entry.
*/

-------------------------------------------------------------------------------
-- Table: Members
-- Contains all club members (including execs).
-------------------------------------------------------------------------------
CREATE TABLE Members (
    member_id       SERIAL PRIMARY KEY,
    member_name     VARCHAR(100) NOT NULL,
    email           VARCHAR(200) NOT NULL UNIQUE,
    level_of_study  VARCHAR(20) NOT NULL  -- e.g. 'Undergraduate', 'Graduate', 'Alumni'
);

COMMENT ON TABLE Members IS
'Stores all GLG members. Each row is one member.';


-------------------------------------------------------------------------------
-- Table: Execs
-- Subclass of Members with additional columns: role, date_assumed
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
'Stores additional info for exec members (role, date_assumed). member_id references Members.';


-------------------------------------------------------------------------------
-- Table: BoardGames
-- Each row is a distinct game (title, min/max players, etc.)
-------------------------------------------------------------------------------
CREATE TABLE BoardGames (
    game_id      SERIAL PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    category     VARCHAR(30) NOT NULL,  -- e.g. 'Strategy', 'Party', etc.
    min_players  INT NOT NULL,
    max_players  INT NOT NULL,
    publisher    VARCHAR(100),
    release_year INT
);

COMMENT ON TABLE BoardGames IS
'Various board game definitions. E.g. "Cascadia," "Blood on the Clocktower," etc.';


-------------------------------------------------------------------------------
-- Table: Copies
-- The club can own multiple copies of the same game.
-------------------------------------------------------------------------------
CREATE TABLE Copies (
    copy_id          SERIAL PRIMARY KEY,
    game_id          INTEGER NOT NULL,
    acquisition_date DATE,
    condition        VARCHAR(20) NOT NULL,  -- e.g. 'New','Lightly-used','Damaged'
    CONSTRAINT fk_copy_game
        FOREIGN KEY (game_id)
        REFERENCES BoardGames (game_id)
);

COMMENT ON TABLE Copies IS
'Physical copies of a particular BoardGame. Each row is one copy.';


-------------------------------------------------------------------------------
-- Table: Events
-- Each row is one event (name, location, date).
-- Same event_name can happen on different dates.
-------------------------------------------------------------------------------
CREATE TABLE Events (
    event_id    SERIAL PRIMARY KEY,
    event_name  VARCHAR(100) NOT NULL,
    location    VARCHAR(100) NOT NULL,
    event_date  DATE NOT NULL
);

COMMENT ON TABLE Events IS
'Various events organized by the club (Weekly Boardgame, special events, etc.)';


-------------------------------------------------------------------------------
-- Table: OrganizingCommittee
-- Which execs are on the committee for a given event. 
-- is_lead indicates if that exec is lead. (We cannot easily enforce "exactly 1" lead.)
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

COMMENT ON TABLE OrganizingCommittee IS
'Link table: which Execs form the organizing team for each event, with possibly one lead.';


-------------------------------------------------------------------------------
-- Table: GameSessions
-- Each event can have multiple sessions. 
-- Each session uses a particular Copy and is facilitated by one exec.
-------------------------------------------------------------------------------
CREATE TABLE GameSessions (
    session_id     SERIAL PRIMARY KEY,
    event_id       INTEGER NOT NULL,
    copy_id        INTEGER NOT NULL,
    facilitated_by INTEGER NOT NULL,  -- must be an Exec
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
'Each row is a single session (tied to one event, uses one copy, facilitated by one exec).';


-------------------------------------------------------------------------------
-- Table: SessionParticipants
-- Many-to-many: members can join multiple sessions, each session can have multiple members.
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
'Which members played in which session. Composite PK: (session_id, member_id).';
