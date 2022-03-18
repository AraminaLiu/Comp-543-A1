-- build double edges
DECLARE
	@E TABLE(
		paperID INTEGER,
		citedPaperID INTEGER
	);

INSERT INTO @E
SELECT * FROM edges;
INSERT INTO @E
SELECT citedPAPERID, paperID
FROM edges;

-- count the number of connected component group
DECLARE
	@num_cg INTEGER; 

-- record total unexplored papers, initialize with all papers
DECLARE @unexplored TABLE( 
	id INTEGER,
	titile VARCHAR(100),
	rn INTEGER
	);

-- within one epoch, record all of childs that will be visited in the next step
DECLARE @frontier TABLE(
	id INTEGER
);

-- within one epoch, record all of childs that has been visited
DECLARE @visited TABLE(
	id INTEGER
);

-- initialize the unexplored set
INSERT INTO @unexplored
SELECT *, ROW_NUMBER() over(order by paperID)
FROM nodes
SET @num_cg = 0;


WHILE EXISTS(SELECT id FROM @unexplored)
BEGIN
	-- initialize the frontier set: pick the paper with the lowest row number
	INSERT INTO @frontier
	SELECT id 
	FROM @unexplored
	WHERE rn = (SELECT MIN(rn) FROM @unexplored);

	-- start epoch to find connected group
	WHILE EXISTS(SELECT id FROM @frontier)
	BEGIN
		-- put fontier set into visited set
		INSERT INTO @visited
		SELECT id FROM @frontier
		WHERE id NOT IN (SELECT id FROM @visited);

		-- frontier update 
		-- 1. find all childs of current frontier nodes and put them into the frontier
		INSERT INTO @frontier
		SELECT DISTINCT citedPaperID
		FROM @E
		WHERE PaperID IN (SELECT id from @frontier) AND citedPaperID NOT IN (SELECT id FROM @visited)

		-- 2. delete already visited nodes from frontier
		DELETE FROM @frontier WHERE id in (SELECT id from @visited)
	END
	;

	-- print out required group
	IF (SELECT COUNT(*) FROM @visited) BETWEEN 5 AND 10
	BEGIN
		SET @num_cg = @num_cg + 1
		PRINT 'Found the target connected group number: ' + CONVERT(VARCHAR, @num_cg)
		PRINT 'The number of papers in this group is:'
		SELECT COUNT(*) FROM @visited
		SELECT * FROM nodes WHERE paperID in (SELECT id from @visited);
	END

	-- update unexplored set
	DELETE FROM @unexplored WHERE id in (SELECT id from @visited);
	
	-- truncate @visited set and @frontier set to restart again
	DELETE FROM @visited;
	DELETE FROM @frontier

END
;



