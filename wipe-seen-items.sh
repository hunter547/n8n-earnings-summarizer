# Wipe everything                                                                                                         
docker compose exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "TRUNCATE seen_items;"'
echo "Cleared out seen_items table"
