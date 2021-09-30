
DO
$$
DECLARE
    sch record;
    view_schema VARCHAR(24);
    scheme_to_drop VARCHAR(36);
    versions VARCHAR(10)[];
    version VARCHAR(10);
BEGIN
    FOR sch IN
        SELECT DISTINCT view_schema_my FROM
            (SELECT substring (schema_name from 0 for 25) AS view_schema_my from information_schema.schemata
        WHERE schema_name LIKE 'tablename____/_v%' ESCAPE '/' ORDER BY schema_name) AS sub
    LOOP
        view_schema := sch.view_schema_my;
        versions := ARRAY['23', '24'];

        FOREACH version IN ARRAY versions
        LOOP
            scheme_to_drop := view_schema || '_' || version;

            RAISE NOTICE 'Detele version %', scheme_to_drop;
            EXECUTE 'DROP SCHEMA ' || scheme_to_drop || ' CASCADE';
        END LOOP;

    END LOOP;
END
$$  LANGUAGE plpgsql;
