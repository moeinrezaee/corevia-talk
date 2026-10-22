CREATE FUNCTION community_deletion_lock_key(target UUID) RETURNS BIGINT
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE AS $$
    SELECT hashtextextended('corevia-talk-community-deletion:' || target::text, 0)
$$;
