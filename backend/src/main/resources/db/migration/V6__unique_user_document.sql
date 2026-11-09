CREATE UNIQUE INDEX uk_app_users_document
ON app_users (
    UPPER(BTRIM(document_type)),
    UPPER(BTRIM(document_number))
)
WHERE document_type IS NOT NULL
AND document_number IS NOT NULL;