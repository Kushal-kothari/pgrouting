/*PGR-GNU*****************************************************************

Copyright (c) 2015 Celia Virginia Vergara Castillo
Mail: project@pgrouting.org

------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

********************************************************************PGR-GNU*/

----------------------
-- pgr_drivingDistance
----------------------

CREATE OR REPLACE FUNCTION _pgr_drivingDistance(
    edges_sql TEXT,
    start_vids ANYARRAY,
    distance FLOAT,
    directed BOOLEAN DEFAULT TRUE,
    equicost BOOLEAN DEFAULT FALSE,
    OUT seq INTEGER,
    OUT from_v  BIGINT,
    OUT node BIGINT,
    OUT edge BIGINT,
    OUT cost FLOAT,
    OUT agg_cost FLOAT)
RETURNS SETOF RECORD AS
'MODULE_PATHNAME', 'driving_many_to_dist'
LANGUAGE c VOLATILE STRICT;

COMMENT ON FUNCTION _pgr_drivingDistance(TEXT, ANYARRAY, FLOAT, BOOLEAN, BOOLEAN)
IS 'pgRouting internal function';


-- MULTIPLE
CREATE OR REPLACE FUNCTION pgr_drivingDistance(
    TEXT,     -- edges_sql (required)
    ANYARRAY, -- from_vids (required)
    FLOAT,    -- distance (required)

    directed BOOLEAN DEFAULT TRUE,
    equicost BOOLEAN DEFAULT FALSE,

    OUT seq INTEGER,
    OUT from_v  BIGINT,
    OUT node BIGINT,
    OUT edge BIGINT,
    OUT cost FLOAT,
    OUT agg_cost FLOAT)
RETURNS SETOF RECORD AS
$BODY$
    SELECT *
    FROM _pgr_drivingDistance(_pgr_get_statement($1), $2, $3, $4, $5);
$BODY$
LANGUAGE SQL VOLATILE STRICT
COST 100
ROWS 1000;


-- SINGLE
CREATE OR REPLACE FUNCTION pgr_drivingDistance(
    TEXT,   -- edges_sql (required)
    BIGINT, -- from_vid (requierd)
    FLOAT,  -- distance (required)

    directed BOOLEAN DEFAULT TRUE,

    OUT seq INTEGER,
    OUT node BIGINT,
    OUT edge BIGINT,
    OUT cost FLOAT,
    OUT agg_cost FLOAT)
RETURNS SETOF RECORD AS
$BODY$
    SELECT seq, node, edge, cost, agg_cost
    FROM _pgr_drivingDistance(_pgr_get_statement($1), ARRAY[$2]::BIGINT[], $3, $4, false);
$BODY$
LANGUAGE SQL VOLATILE STRICT
COST 100
ROWS 1000;

-- COMMENTS

COMMENT ON FUNCTION pgr_drivingDistance(TEXT, BIGINT, FLOAT, BOOLEAN)
IS 'pgr_drivingDistance(Single_vertex) -- edges_sql(id,source,target,cost[,reverse_cost]), from_vid, distance [,directed]';
COMMENT ON FUNCTION pgr_drivingDistance(TEXT, ANYARRAY, FLOAT, BOOLEAN, BOOLEAN)
IS 'pgr_drivingDistance(Multiple vertices) -- edges_sql(id,source,target,cost[,reverse_cost]), from_vids, distance [,directed, equicost]';

