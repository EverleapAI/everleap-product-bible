-- Everleap database schema (structure only, no data).
-- Regenerate:  pg_dump $POSTGRES_URL --schema-only --no-owner --no-privileges --no-comments
-- The \restrict tokens pg_dump 18 emits are stripped so this file diffs cleanly.

--
-- PostgreSQL database dump
--


-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action_reflections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_reflections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    action_id uuid NOT NULL,
    text text NOT NULL,
    felt text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_model_pricing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_model_pricing (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider text NOT NULL,
    model text NOT NULL,
    input_usd_per_1m_tokens numeric(12,6) NOT NULL,
    output_usd_per_1m_tokens numeric(12,6) NOT NULL,
    cached_input_usd_per_1m_tokens numeric(12,6),
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_usage_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_usage_audit (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    provider text NOT NULL,
    model text NOT NULL,
    feature text NOT NULL,
    input_tokens integer DEFAULT 0 NOT NULL,
    output_tokens integer DEFAULT 0 NOT NULL,
    cached_input_tokens integer DEFAULT 0 NOT NULL,
    input_cost_usd numeric(12,6) DEFAULT 0 NOT NULL,
    output_cost_usd numeric(12,6) DEFAULT 0 NOT NULL,
    cached_input_cost_usd numeric(12,6) DEFAULT 0 NOT NULL,
    estimated_cost_usd numeric(12,6) DEFAULT 0 NOT NULL,
    request_id text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    actor_type text DEFAULT 'unknown'::text NOT NULL,
    source text DEFAULT 'unknown'::text NOT NULL,
    prompt_mode text,
    template_key text
);


--
-- Name: badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges (
    slug text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    hint text,
    row_index integer NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    accent text DEFAULT 'amber'::text NOT NULL,
    glyph text DEFAULT '◆'::text NOT NULL,
    criteria jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    high_signal_criteria jsonb,
    high_signal_hint text,
    bronze_criteria jsonb,
    silver_criteria jsonb,
    gold_criteria jsonb,
    bronze_hint text,
    silver_hint text,
    gold_hint text
);


--
-- Name: career_ladder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.career_ladder (
    lane text NOT NULL,
    path_slug text NOT NULL,
    rungs jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: constellation_lit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constellation_lit (
    user_id uuid NOT NULL,
    path_slug text NOT NULL,
    branch_slug text DEFAULT ''::text NOT NULL,
    star_id text NOT NULL,
    lit_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: day_scene_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.day_scene_images (
    path_slug text NOT NULL,
    moment_id text NOT NULL,
    image_bytes bytea NOT NULL,
    image_content_type text DEFAULT 'image/jpeg'::text NOT NULL,
    image_model text,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    branch_slug text DEFAULT ''::text NOT NULL
);


--
-- Name: email_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_codes (
    id uuid NOT NULL,
    email text NOT NULL,
    code_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: explore_path_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.explore_path_matches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    path_id text NOT NULL,
    lane text NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    rank integer,
    why_you text,
    reasons jsonb DEFAULT '[]'::jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    card_why text
);


--
-- Name: explore_path_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.explore_path_views (
    user_id uuid NOT NULL,
    path_key text NOT NULL,
    lane text NOT NULL,
    views integer DEFAULT 1 NOT NULL,
    first_viewed_at timestamp with time zone DEFAULT now() NOT NULL,
    last_viewed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: explore_paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.explore_paths (
    id text NOT NULL,
    lane text NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    taxonomy_code text,
    content jsonb NOT NULL,
    sources jsonb DEFAULT '[]'::jsonb NOT NULL,
    embedding jsonb,
    source_version text,
    content_model text DEFAULT 'on-demand'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: explore_user_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.explore_user_summary (
    user_id uuid NOT NULL,
    input_hash text NOT NULL,
    payload jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: flow_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_nodes (
    id uuid NOT NULL,
    flow_id uuid NOT NULL,
    key text NOT NULL,
    node_type text NOT NULL,
    sort_order integer NOT NULL,
    title text,
    body text NOT NULL,
    question_key text,
    is_required boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: flows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flows (
    id uuid NOT NULL,
    key text NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: generation_input_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generation_input_hashes (
    user_id uuid NOT NULL,
    cache_key text NOT NULL,
    input_hash text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: insights_card_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insights_card_reactions (
    user_id uuid NOT NULL,
    page_key text NOT NULL,
    item_key text NOT NULL,
    reaction text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: insights_summary_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insights_summary_feedback (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    page_key text DEFAULT 'insights_summary'::text NOT NULL,
    rating text NOT NULL,
    note text,
    source_guidance_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT insights_summary_feedback_rating_check CHECK ((rating = ANY (ARRAY['mostly'::text, 'somewhat'::text, 'not_really'::text])))
);


--
-- Name: live_door_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.live_door_cache (
    source text NOT NULL,
    cache_key text NOT NULL,
    payload jsonb NOT NULL,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: onet_occupations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onet_occupations (
    code text NOT NULL,
    soc text,
    title text,
    profile jsonb NOT NULL,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: passkeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passkeys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    credential_id text NOT NULL,
    public_key text NOT NULL,
    counter bigint DEFAULT 0 NOT NULL,
    device_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone,
    transports jsonb,
    device_type text,
    backed_up boolean
);


--
-- Name: prompt_lab_rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prompt_lab_rate_limits (
    user_id uuid NOT NULL,
    action text NOT NULL,
    window_start timestamp with time zone NOT NULL,
    request_count integer DEFAULT 0 NOT NULL
);


--
-- Name: prompt_lab_unlocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prompt_lab_unlocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);


--
-- Name: question_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_options (
    id uuid NOT NULL,
    question_id uuid NOT NULL,
    key text NOT NULL,
    label text NOT NULL,
    description text,
    image_url text,
    sort_order integer NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: question_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    label text NOT NULL,
    allows_options boolean DEFAULT false NOT NULL,
    allows_multiple boolean DEFAULT false NOT NULL,
    allows_comment boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id uuid NOT NULL,
    key text NOT NULL,
    family text NOT NULL,
    prompt text NOT NULL,
    input_type text NOT NULL,
    placeholder text,
    min_length integer,
    max_length integer,
    validation_rules jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    source_sheet text,
    source_row integer,
    source_section text,
    source_rank integer,
    goal text,
    science text,
    core_characteristic text,
    answer_type_raw text,
    user_audience text,
    citation text,
    notes text,
    goal_family text,
    question_type_id uuid,
    question_weight integer DEFAULT 50 NOT NULL,
    CONSTRAINT questions_question_weight_range CHECK (((question_weight >= 1) AND (question_weight <= 100)))
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);


--
-- Name: specialty_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specialty_content (
    career_slug text NOT NULL,
    branch_slug text NOT NULL,
    content jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    lane text DEFAULT 'work'::text NOT NULL
);


--
-- Name: story_question_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.story_question_answers (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    question_id uuid NOT NULL,
    answer_text text,
    answer_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: time_twin_figures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_twin_figures (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    era text DEFAULT ''::text NOT NULL,
    tagline text DEFAULT ''::text NOT NULL,
    mind_type text DEFAULT ''::text NOT NULL,
    visual_profile_key text DEFAULT 'scientist'::text NOT NULL,
    tiles jsonb DEFAULT '[]'::jsonb NOT NULL,
    story_beats jsonb DEFAULT '[]'::jsonb NOT NULL,
    superpower text DEFAULT ''::text NOT NULL,
    watchout text DEFAULT ''::text NOT NULL,
    try_this_week text DEFAULT ''::text NOT NULL,
    learn_more_href text DEFAULT ''::text NOT NULL,
    pattern_signature text DEFAULT ''::text NOT NULL,
    embedding jsonb,
    image_bytes bytea,
    image_content_type text DEFAULT 'image/jpeg'::text NOT NULL,
    image_model text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: time_twin_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_twin_reactions (
    user_id uuid NOT NULL,
    figure_slug text NOT NULL,
    reaction text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: time_twin_reflections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_twin_reflections (
    user_id uuid NOT NULL,
    twin_id text NOT NULL,
    reflection text DEFAULT ''::text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: today_dispatch_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.today_dispatch_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    dispatch_type text NOT NULL,
    dispatch_key text,
    destination_route text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    acted_at timestamp with time zone,
    dismissed_at timestamp with time zone
);


--
-- Name: us_zip_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.us_zip_codes (
    zip_code text NOT NULL,
    city text,
    state text,
    latitude numeric,
    longitude numeric
);


--
-- Name: user_action_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_action_suggestions (
    user_id uuid NOT NULL,
    input_hash text NOT NULL,
    payload jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    source_type text NOT NULL,
    source_ref text,
    lane text,
    title text NOT NULL,
    description text,
    href text,
    status text DEFAULT 'saved'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mission jsonb,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    reflection text,
    felt text
);


--
-- Name: user_badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_badges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    badge_slug text NOT NULL,
    earned_at timestamp with time zone DEFAULT now() NOT NULL,
    high_signal_at timestamp with time zone,
    bronze_at timestamp with time zone,
    silver_at timestamp with time zone,
    gold_at timestamp with time zone
);


--
-- Name: user_content_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_content_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    channel text DEFAULT 'app'::text NOT NULL,
    event_type text DEFAULT 'page_viewed'::text NOT NULL,
    page_key text NOT NULL,
    target text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_generation_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_generation_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    target_key text NOT NULL,
    trigger text NOT NULL,
    priority integer DEFAULT 50 NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    run_after timestamp with time zone DEFAULT now() NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    failed_at timestamp with time zone,
    attempts integer DEFAULT 0 NOT NULL,
    error_message text,
    source_snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    unique_key text NOT NULL,
    execution_mode text DEFAULT 'deferred'::text NOT NULL,
    CONSTRAINT user_generation_requests_execution_mode_check CHECK ((execution_mode = ANY (ARRAY['deferred'::text, 'immediate'::text, 'blocking'::text])))
);


--
-- Name: user_interest_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_interest_profiles (
    user_id uuid NOT NULL,
    realistic integer DEFAULT 0 NOT NULL,
    investigative integer DEFAULT 0 NOT NULL,
    artistic integer DEFAULT 0 NOT NULL,
    social integer DEFAULT 0 NOT NULL,
    enterprising integer DEFAULT 0 NOT NULL,
    conventional integer DEFAULT 0 NOT NULL,
    source text DEFAULT 'inferred'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_memory_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_memory_profile (
    user_id uuid NOT NULL,
    long_horizon_summary text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    self_portrait jsonb,
    self_portrait_hash text
);


--
-- Name: user_micro_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_micro_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    page_key text DEFAULT 'today'::text NOT NULL,
    signal_key text NOT NULL,
    question text NOT NULL,
    options_json jsonb NOT NULL,
    selected_option text,
    selected_option_index integer,
    source_guidance_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    answered_at timestamp with time zone,
    batch_id uuid DEFAULT gen_random_uuid() NOT NULL,
    batch_position smallint DEFAULT 0 NOT NULL
);


--
-- Name: user_page_guidance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_page_guidance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    page_key text NOT NULL,
    guidance_text text NOT NULL,
    next_action_label text,
    next_action_route text,
    generation_trigger text,
    source_snapshot jsonb DEFAULT '{}'::jsonb,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    headline text,
    opening_paragraph text,
    next_paragraph text
);


--
-- Name: user_question_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_question_answers (
    id uuid NOT NULL,
    user_id uuid,
    flow_id uuid NOT NULL,
    flow_node_id uuid,
    question_id uuid NOT NULL,
    answer_text text,
    answer_json jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_science_insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_science_insights (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    science text NOT NULL,
    confidence numeric DEFAULT 0 NOT NULL,
    hypotheses_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    missing_information_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    questions_to_reduce_uncertainty_json jsonb DEFAULT '[]'::jsonb CONSTRAINT user_science_insights_questions_to_reduce_uncertainty__not_null NOT NULL,
    evidence_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    source_snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email text,
    email_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    current_challenge text,
    webauthn_user_id text,
    zip_code text,
    phone text,
    phone_verified boolean DEFAULT false NOT NULL,
    first_name text,
    has_seen_intro boolean DEFAULT false NOT NULL
);


--
-- Name: action_reflections action_reflections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_reflections
    ADD CONSTRAINT action_reflections_pkey PRIMARY KEY (id);


--
-- Name: ai_model_pricing ai_model_pricing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_model_pricing
    ADD CONSTRAINT ai_model_pricing_pkey PRIMARY KEY (id);


--
-- Name: ai_usage_audit ai_usage_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_audit
    ADD CONSTRAINT ai_usage_audit_pkey PRIMARY KEY (id);


--
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (slug);


--
-- Name: career_ladder career_ladder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.career_ladder
    ADD CONSTRAINT career_ladder_pkey PRIMARY KEY (lane, path_slug);


--
-- Name: constellation_lit constellation_lit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constellation_lit
    ADD CONSTRAINT constellation_lit_pkey PRIMARY KEY (user_id, path_slug, branch_slug, star_id);


--
-- Name: day_scene_images day_scene_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.day_scene_images
    ADD CONSTRAINT day_scene_images_pkey PRIMARY KEY (path_slug, branch_slug, moment_id);


--
-- Name: email_codes email_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_codes
    ADD CONSTRAINT email_codes_pkey PRIMARY KEY (id);


--
-- Name: explore_path_matches explore_path_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_path_matches
    ADD CONSTRAINT explore_path_matches_pkey PRIMARY KEY (id);


--
-- Name: explore_path_matches explore_path_matches_user_path_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_path_matches
    ADD CONSTRAINT explore_path_matches_user_path_key UNIQUE (user_id, path_id);


--
-- Name: explore_path_views explore_path_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_path_views
    ADD CONSTRAINT explore_path_views_pkey PRIMARY KEY (user_id, path_key);


--
-- Name: explore_paths explore_paths_lane_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_paths
    ADD CONSTRAINT explore_paths_lane_slug_key UNIQUE (lane, slug);


--
-- Name: explore_paths explore_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_paths
    ADD CONSTRAINT explore_paths_pkey PRIMARY KEY (id);


--
-- Name: explore_user_summary explore_user_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_user_summary
    ADD CONSTRAINT explore_user_summary_pkey PRIMARY KEY (user_id);


--
-- Name: flow_nodes flow_nodes_flow_id_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_nodes
    ADD CONSTRAINT flow_nodes_flow_id_key_key UNIQUE (flow_id, key);


--
-- Name: flow_nodes flow_nodes_flow_id_sort_order_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_nodes
    ADD CONSTRAINT flow_nodes_flow_id_sort_order_key UNIQUE (flow_id, sort_order);


--
-- Name: flow_nodes flow_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_nodes
    ADD CONSTRAINT flow_nodes_pkey PRIMARY KEY (id);


--
-- Name: flows flows_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flows
    ADD CONSTRAINT flows_key_key UNIQUE (key);


--
-- Name: flows flows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flows
    ADD CONSTRAINT flows_pkey PRIMARY KEY (id);


--
-- Name: generation_input_hashes generation_input_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generation_input_hashes
    ADD CONSTRAINT generation_input_hashes_pkey PRIMARY KEY (user_id, cache_key);


--
-- Name: insights_card_reactions insights_card_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights_card_reactions
    ADD CONSTRAINT insights_card_reactions_pkey PRIMARY KEY (user_id, page_key, item_key);


--
-- Name: insights_summary_feedback insights_summary_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights_summary_feedback
    ADD CONSTRAINT insights_summary_feedback_pkey PRIMARY KEY (id);


--
-- Name: live_door_cache live_door_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_door_cache
    ADD CONSTRAINT live_door_cache_pkey PRIMARY KEY (source, cache_key);


--
-- Name: onet_occupations onet_occupations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onet_occupations
    ADD CONSTRAINT onet_occupations_pkey PRIMARY KEY (code);


--
-- Name: passkeys passkeys_credential_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_credential_id_key UNIQUE (credential_id);


--
-- Name: passkeys passkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_pkey PRIMARY KEY (id);


--
-- Name: prompt_lab_rate_limits prompt_lab_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prompt_lab_rate_limits
    ADD CONSTRAINT prompt_lab_rate_limits_pkey PRIMARY KEY (user_id, action, window_start);


--
-- Name: prompt_lab_unlocks prompt_lab_unlocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prompt_lab_unlocks
    ADD CONSTRAINT prompt_lab_unlocks_pkey PRIMARY KEY (id);


--
-- Name: question_options question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_pkey PRIMARY KEY (id);


--
-- Name: question_options question_options_question_id_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_question_id_key_key UNIQUE (question_id, key);


--
-- Name: question_options question_options_question_id_sort_order_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_question_id_sort_order_key UNIQUE (question_id, sort_order);


--
-- Name: question_types question_types_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_types
    ADD CONSTRAINT question_types_key_key UNIQUE (key);


--
-- Name: question_types question_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_types
    ADD CONSTRAINT question_types_pkey PRIMARY KEY (id);


--
-- Name: questions questions_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_key_key UNIQUE (key);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_token_hash_key UNIQUE (token_hash);


--
-- Name: specialty_content specialty_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialty_content
    ADD CONSTRAINT specialty_content_pkey PRIMARY KEY (lane, career_slug, branch_slug);


--
-- Name: story_question_answers story_question_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.story_question_answers
    ADD CONSTRAINT story_question_answers_pkey PRIMARY KEY (id);


--
-- Name: story_question_answers story_question_answers_user_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.story_question_answers
    ADD CONSTRAINT story_question_answers_user_id_question_id_key UNIQUE (user_id, question_id);


--
-- Name: time_twin_figures time_twin_figures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_figures
    ADD CONSTRAINT time_twin_figures_pkey PRIMARY KEY (id);


--
-- Name: time_twin_figures time_twin_figures_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_figures
    ADD CONSTRAINT time_twin_figures_slug_key UNIQUE (slug);


--
-- Name: time_twin_reactions time_twin_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_reactions
    ADD CONSTRAINT time_twin_reactions_pkey PRIMARY KEY (user_id, figure_slug);


--
-- Name: time_twin_reflections time_twin_reflections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_reflections
    ADD CONSTRAINT time_twin_reflections_pkey PRIMARY KEY (user_id, twin_id);


--
-- Name: today_dispatch_log today_dispatch_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.today_dispatch_log
    ADD CONSTRAINT today_dispatch_log_pkey PRIMARY KEY (id);


--
-- Name: us_zip_codes us_zip_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.us_zip_codes
    ADD CONSTRAINT us_zip_codes_pkey PRIMARY KEY (zip_code);


--
-- Name: user_action_suggestions user_action_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_action_suggestions
    ADD CONSTRAINT user_action_suggestions_pkey PRIMARY KEY (user_id);


--
-- Name: user_actions user_actions_dedupe; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_dedupe UNIQUE (user_id, source_type, source_ref, title);


--
-- Name: user_actions user_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: user_badges user_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_pkey PRIMARY KEY (id);


--
-- Name: user_badges user_badges_user_id_badge_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_user_id_badge_slug_key UNIQUE (user_id, badge_slug);


--
-- Name: user_content_events user_content_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_content_events
    ADD CONSTRAINT user_content_events_pkey PRIMARY KEY (id);


--
-- Name: user_generation_requests user_generation_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_generation_requests
    ADD CONSTRAINT user_generation_requests_pkey PRIMARY KEY (id);


--
-- Name: user_interest_profiles user_interest_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_interest_profiles
    ADD CONSTRAINT user_interest_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: user_memory_profile user_memory_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_memory_profile
    ADD CONSTRAINT user_memory_profile_pkey PRIMARY KEY (user_id);


--
-- Name: user_micro_tasks user_micro_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_micro_tasks
    ADD CONSTRAINT user_micro_tasks_pkey PRIMARY KEY (id);


--
-- Name: user_page_guidance user_page_guidance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_page_guidance
    ADD CONSTRAINT user_page_guidance_pkey PRIMARY KEY (id);


--
-- Name: user_page_guidance user_page_guidance_user_id_page_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_page_guidance
    ADD CONSTRAINT user_page_guidance_user_id_page_key_key UNIQUE (user_id, page_key);


--
-- Name: user_question_answers user_question_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_pkey PRIMARY KEY (id);


--
-- Name: user_question_answers user_question_answers_user_id_flow_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_user_id_flow_id_question_id_key UNIQUE (user_id, flow_id, question_id);


--
-- Name: user_science_insights user_science_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_science_insights
    ADD CONSTRAINT user_science_insights_pkey PRIMARY KEY (id);


--
-- Name: user_science_insights user_science_insights_user_id_science_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_science_insights
    ADD CONSTRAINT user_science_insights_user_id_science_key UNIQUE (user_id, science);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: action_reflections_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_reflections_action_idx ON public.action_reflections USING btree (action_id, created_at);


--
-- Name: action_reflections_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_reflections_user_idx ON public.action_reflections USING btree (user_id);


--
-- Name: constellation_lit_user_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX constellation_lit_user_path_idx ON public.constellation_lit USING btree (user_id, path_slug, branch_slug);


--
-- Name: email_codes_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX email_codes_email_idx ON public.email_codes USING btree (email);


--
-- Name: explore_path_views_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX explore_path_views_user_idx ON public.explore_path_views USING btree (user_id);


--
-- Name: explore_path_views_user_lane_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX explore_path_views_user_lane_idx ON public.explore_path_views USING btree (user_id, lane);


--
-- Name: idx_ai_model_pricing_provider_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_model_pricing_provider_model ON public.ai_model_pricing USING btree (provider, model);


--
-- Name: idx_ai_usage_actor_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_actor_type ON public.ai_usage_audit USING btree (actor_type);


--
-- Name: idx_ai_usage_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_created_at ON public.ai_usage_audit USING btree (created_at DESC);


--
-- Name: idx_ai_usage_feature; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_feature ON public.ai_usage_audit USING btree (feature);


--
-- Name: idx_ai_usage_prompt_mode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_prompt_mode ON public.ai_usage_audit USING btree (prompt_mode);


--
-- Name: idx_ai_usage_provider_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_provider_model ON public.ai_usage_audit USING btree (provider, model);


--
-- Name: idx_ai_usage_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_source ON public.ai_usage_audit USING btree (source);


--
-- Name: idx_ai_usage_template_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_template_key ON public.ai_usage_audit USING btree (template_key);


--
-- Name: idx_ai_usage_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_usage_user_id ON public.ai_usage_audit USING btree (user_id);


--
-- Name: idx_explore_path_matches_user_lane; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_explore_path_matches_user_lane ON public.explore_path_matches USING btree (user_id, lane, rank);


--
-- Name: idx_explore_paths_lane; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_explore_paths_lane ON public.explore_paths USING btree (lane);


--
-- Name: idx_explore_paths_taxonomy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_explore_paths_taxonomy ON public.explore_paths USING btree (taxonomy_code);


--
-- Name: idx_flow_nodes_flow_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flow_nodes_flow_sort ON public.flow_nodes USING btree (flow_id, sort_order);


--
-- Name: idx_insights_summary_feedback_user_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_insights_summary_feedback_user_page ON public.insights_summary_feedback USING btree (user_id, page_key, created_at DESC);


--
-- Name: idx_passkeys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_passkeys_user_id ON public.passkeys USING btree (user_id);


--
-- Name: idx_prompt_lab_unlocks_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_prompt_lab_unlocks_token_hash ON public.prompt_lab_unlocks USING btree (token_hash);


--
-- Name: idx_prompt_lab_unlocks_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_prompt_lab_unlocks_user ON public.prompt_lab_unlocks USING btree (user_id, created_at DESC);


--
-- Name: idx_question_options_question_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_question_options_question_sort ON public.question_options USING btree (question_id, sort_order);


--
-- Name: idx_time_twin_figures_visual_profile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_time_twin_figures_visual_profile ON public.time_twin_figures USING btree (visual_profile_key);


--
-- Name: idx_user_actions_user_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_actions_user_source ON public.user_actions USING btree (user_id, source_type, source_ref);


--
-- Name: idx_user_actions_user_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_actions_user_status ON public.user_actions USING btree (user_id, status, created_at DESC);


--
-- Name: idx_user_content_events_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_content_events_user_created ON public.user_content_events USING btree (user_id, created_at DESC);


--
-- Name: idx_user_micro_tasks_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_micro_tasks_batch_id ON public.user_micro_tasks USING btree (batch_id);


--
-- Name: idx_user_micro_tasks_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_micro_tasks_user_created ON public.user_micro_tasks USING btree (user_id, created_at DESC);


--
-- Name: idx_user_micro_tasks_user_page_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_micro_tasks_user_page_created ON public.user_micro_tasks USING btree (user_id, page_key, created_at DESC);


--
-- Name: idx_user_micro_tasks_user_signal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_micro_tasks_user_signal ON public.user_micro_tasks USING btree (user_id, signal_key, created_at DESC);


--
-- Name: idx_user_page_guidance_user_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_page_guidance_user_page ON public.user_page_guidance USING btree (user_id, page_key);


--
-- Name: idx_user_question_answers_user_flow; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_question_answers_user_flow ON public.user_question_answers USING btree (user_id, flow_id);


--
-- Name: idx_user_science_insights_science; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_science_insights_science ON public.user_science_insights USING btree (science);


--
-- Name: idx_user_science_insights_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_science_insights_user_id ON public.user_science_insights USING btree (user_id);


--
-- Name: insights_card_reactions_user_page_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX insights_card_reactions_user_page_idx ON public.insights_card_reactions USING btree (user_id, page_key);


--
-- Name: live_door_cache_fetched_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX live_door_cache_fetched_idx ON public.live_door_cache USING btree (fetched_at);


--
-- Name: questions_source_sheet_source_row_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX questions_source_sheet_source_row_idx ON public.questions USING btree (source_sheet, source_row) WHERE ((source_sheet IS NOT NULL) AND (source_row IS NOT NULL));


--
-- Name: story_question_answers_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX story_question_answers_user_id_idx ON public.story_question_answers USING btree (user_id);


--
-- Name: time_twin_reactions_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX time_twin_reactions_user_idx ON public.time_twin_reactions USING btree (user_id);


--
-- Name: today_dispatch_log_user_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX today_dispatch_log_user_created_idx ON public.today_dispatch_log USING btree (user_id, created_at DESC);


--
-- Name: user_badges_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_badges_user_idx ON public.user_badges USING btree (user_id);


--
-- Name: user_generation_requests_unique_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_generation_requests_unique_pending ON public.user_generation_requests USING btree (user_id, target_key, unique_key) WHERE (status = ANY (ARRAY['pending'::text, 'running'::text]));


--
-- Name: user_generation_requests_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_generation_requests_user_idx ON public.user_generation_requests USING btree (user_id, requested_at DESC);


--
-- Name: user_generation_requests_worker_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_generation_requests_worker_idx ON public.user_generation_requests USING btree (status, run_after, priority DESC, requested_at) WHERE (status = 'pending'::text);


--
-- Name: action_reflections action_reflections_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_reflections
    ADD CONSTRAINT action_reflections_action_id_fkey FOREIGN KEY (action_id) REFERENCES public.user_actions(id) ON DELETE CASCADE;


--
-- Name: action_reflections action_reflections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_reflections
    ADD CONSTRAINT action_reflections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_usage_audit ai_usage_audit_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_audit
    ADD CONSTRAINT ai_usage_audit_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: constellation_lit constellation_lit_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constellation_lit
    ADD CONSTRAINT constellation_lit_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: explore_path_matches explore_path_matches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_path_matches
    ADD CONSTRAINT explore_path_matches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: explore_path_views explore_path_views_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_path_views
    ADD CONSTRAINT explore_path_views_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: explore_user_summary explore_user_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.explore_user_summary
    ADD CONSTRAINT explore_user_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ai_usage_audit fk_ai_usage_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_audit
    ADD CONSTRAINT fk_ai_usage_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: flow_nodes flow_nodes_flow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_nodes
    ADD CONSTRAINT flow_nodes_flow_id_fkey FOREIGN KEY (flow_id) REFERENCES public.flows(id) ON DELETE CASCADE;


--
-- Name: generation_input_hashes generation_input_hashes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generation_input_hashes
    ADD CONSTRAINT generation_input_hashes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: insights_card_reactions insights_card_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights_card_reactions
    ADD CONSTRAINT insights_card_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: insights_summary_feedback insights_summary_feedback_source_guidance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights_summary_feedback
    ADD CONSTRAINT insights_summary_feedback_source_guidance_id_fkey FOREIGN KEY (source_guidance_id) REFERENCES public.user_page_guidance(id);


--
-- Name: insights_summary_feedback insights_summary_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insights_summary_feedback
    ADD CONSTRAINT insights_summary_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: passkeys passkeys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: prompt_lab_rate_limits prompt_lab_rate_limits_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prompt_lab_rate_limits
    ADD CONSTRAINT prompt_lab_rate_limits_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: prompt_lab_unlocks prompt_lab_unlocks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prompt_lab_unlocks
    ADD CONSTRAINT prompt_lab_unlocks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: question_options question_options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: questions questions_question_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_question_type_id_fkey FOREIGN KEY (question_type_id) REFERENCES public.question_types(id);


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: story_question_answers story_question_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.story_question_answers
    ADD CONSTRAINT story_question_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: time_twin_reactions time_twin_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_reactions
    ADD CONSTRAINT time_twin_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: time_twin_reflections time_twin_reflections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_twin_reflections
    ADD CONSTRAINT time_twin_reflections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: today_dispatch_log today_dispatch_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.today_dispatch_log
    ADD CONSTRAINT today_dispatch_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_action_suggestions user_action_suggestions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_action_suggestions
    ADD CONSTRAINT user_action_suggestions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_actions user_actions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_badges user_badges_badge_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_badge_slug_fkey FOREIGN KEY (badge_slug) REFERENCES public.badges(slug) ON DELETE CASCADE;


--
-- Name: user_badges user_badges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_content_events user_content_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_content_events
    ADD CONSTRAINT user_content_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_generation_requests user_generation_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_generation_requests
    ADD CONSTRAINT user_generation_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_memory_profile user_memory_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_memory_profile
    ADD CONSTRAINT user_memory_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_page_guidance user_page_guidance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_page_guidance
    ADD CONSTRAINT user_page_guidance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_question_answers user_question_answers_flow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_flow_id_fkey FOREIGN KEY (flow_id) REFERENCES public.flows(id) ON DELETE CASCADE;


--
-- Name: user_question_answers user_question_answers_flow_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_flow_node_id_fkey FOREIGN KEY (flow_node_id) REFERENCES public.flow_nodes(id) ON DELETE SET NULL;


--
-- Name: user_question_answers user_question_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: user_question_answers user_question_answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_question_answers
    ADD CONSTRAINT user_question_answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


