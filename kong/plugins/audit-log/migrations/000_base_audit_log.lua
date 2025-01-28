return {
    postgres = {
      up = [[
        CREATE TABLE IF NOT EXISTS "public"."audit_log" (
            "id" serial,
            "entity" text,
            "entity_name" text,
            "entity_id" text,
            "operation" text,
            "old_data" jsonb,
            "new_data" jsonb,
            "performed_at" timestamptz DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
            "action_by" text,
            PRIMARY KEY ("id")
        );
        
        CREATE OR REPLACE FUNCTION public.consumer_created()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_name, entity_id, new_data, operation, action_by)
            VALUES('consumer', NEW.username, NEW.id, json_build_object('custom_id', NEW.custom_id, 'tags', NEW.tags), 'created', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS consumer_created ON consumers;
        CREATE TRIGGER consumer_created
        AFTER INSERT
        ON consumers
        FOR EACH ROW
        EXECUTE PROCEDURE consumer_created();
        
        CREATE OR REPLACE FUNCTION public.consumer_deleted()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_name, entity_id, old_data, operation, action_by)
            VALUES('consumer', OLD.username, OLD.id, json_build_object('custom_id', OLD.custom_id, 'tags', OLD.tags), 'deleted', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS consumer_deleted ON consumers;
        CREATE TRIGGER consumer_deleted
        AFTER DELETE
        ON consumers
        FOR EACH ROW
        EXECUTE PROCEDURE consumer_deleted();
        
        CREATE OR REPLACE FUNCTION public.consumer_updated()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_name, entity_id, old_data, new_data, operation, action_by)
            VALUES('consumer', NEW.username, NEW.id, json_build_object('custom_id', OLD.custom_id, 'tags', OLD.tags), json_build_object('custom_id', NEW.custom_id, 'tags', NEW.tags), 'updated', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS consumer_updated ON consumers;
        CREATE TRIGGER consumer_updated
        AFTER UPDATE
        ON consumers
        FOR EACH ROW
        EXECUTE PROCEDURE consumer_updated();
        
        CREATE OR REPLACE FUNCTION public.rate_limit_created()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            IF NEW.name='rate-limiting' THEN
                INSERT INTO audit_log(entity, entity_name, entity_id, new_data, operation, action_by)
                VALUES('plugin', NEW.name, NEW.id, json_build_object('consumer_id', NEW.consumer_id, 'service_id', NEW.service_id, 'config', NEW.config), 'created', concat(session_user, '@', inet_client_addr()));
            END IF;
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS rate_limit_created ON plugins;
        CREATE TRIGGER rate_limit_created
        AFTER INSERT
        ON plugins
        FOR EACH ROW
        EXECUTE PROCEDURE rate_limit_created();
        
        CREATE OR REPLACE FUNCTION public.rate_limit_deleted()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            IF OLD.name='rate-limiting' THEN
                INSERT INTO audit_log(entity, entity_name, entity_id, old_data, operation, action_by)
                VALUES('plugin', OLD.name, OLD.id, json_build_object('consumer_id', OLD.consumer_id, 'service_id', OLD.service_id, 'config', OLD.config), 'deleted', concat(session_user, '@', inet_client_addr()));
            END IF;
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS rate_limit_deleted ON plugins;
        CREATE TRIGGER rate_limit_deleted
        AFTER DELETE
        ON plugins
        FOR EACH ROW
        EXECUTE PROCEDURE rate_limit_deleted();
        
        CREATE OR REPLACE FUNCTION public.rate_limit_updated()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            IF OLD.name='rate-limiting' THEN
                INSERT INTO audit_log(entity, entity_name, entity_id, old_data, new_data, operation, action_by)
                VALUES('plugin', OLD.name, OLD.id, json_build_object('consumer_id', OLD.consumer_id, 'service_id', OLD.service_id, 'config', OLD.config), json_build_object('consumer_id', NEW.consumer_id, 'service_id', NEW.service_id, 'config', NEW.config), 'updated', concat(session_user, '@', inet_client_addr()));
            END IF;
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS rate_limit_updated ON plugins;
        CREATE TRIGGER rate_limit_updated
        AFTER UPDATE
        ON plugins
        FOR EACH ROW
        EXECUTE PROCEDURE rate_limit_updated();

        CREATE OR REPLACE FUNCTION public.basicauth_credentials_created()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_id, new_data, operation, action_by)
            VALUES('basicauth_credentials', NEW.id, json_build_object('consumer_id', NEW.consumer_id, 'username', NEW.username, 'password', NEW.password), 'created', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS basicauth_credentials_created ON basicauth_credentials;
        CREATE TRIGGER basicauth_credentials_created
        AFTER INSERT
        ON basicauth_credentials
        FOR EACH ROW
        EXECUTE PROCEDURE basicauth_credentials_created();
        
        CREATE OR REPLACE FUNCTION public.basicauth_credentials_deleted()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_id, old_data, operation, action_by)
            VALUES('basicauth_credentials', OLD.id, json_build_object('consumer_id', OLD.consumer_id, 'username', OLD.username, 'password', OLD.password), 'deleted', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS basicauth_credentials_deleted ON basicauth_credentials;
        CREATE TRIGGER basicauth_credentials_deleted
        AFTER DELETE
        ON basicauth_credentials
        FOR EACH ROW
        EXECUTE PROCEDURE basicauth_credentials_deleted();
        
        CREATE OR REPLACE FUNCTION public.basicauth_credentials_updated()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        BEGIN
            INSERT INTO audit_log(entity, entity_id, old_data, new_data, operation, action_by)
            VALUES('basicauth_credentials', OLD.id, json_build_object('consumer_id', OLD.consumer_id, 'username', OLD.username, 'password', OLD.password), json_build_object('consumer_id', NEW.consumer_id, 'username', NEW.username, 'password', NEW.password), 'deleted', concat(session_user, '@', inet_client_addr()));
            RETURN NEW;
        END;
        $function$;
        
        DROP TRIGGER IF EXISTS basicauth_credentials_updated ON basicauth_credentials;
        CREATE TRIGGER basicauth_credentials_updated
        AFTER UPDATE
        ON basicauth_credentials
        FOR EACH ROW
        EXECUTE PROCEDURE basicauth_credentials_updated();
      ]]
    },
}
