-- 1. Table creation (Fixed trailing comma)
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text unique not null,
    role text default 'user' not null -- No comma here
);

-- 2. Function (Added SECURITY DEFINER)
-- CRITICAL: 'security definer' ke bina trigger profiles table mein 
-- insert nahi kar payega kyunki naye user ke paas permissions nahi hoti.
create or replace function public.handle_new_user()
returns trigger 
language plpgsql
security definer set search_path = public
as $$
begin
    insert into public.profiles (id, email)
    values (new.id, new.email);
    return new;
end;
$$;

-- 3. Trigger
-- Note: Agar pehle se bana hua hai toh 'drop' logic add karna safe rehta hai
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users 
for each row execute procedure public.handle_new_user();