--
-- PostgreSQL database dump
--

\restrict 5HC0Nr4olNusxAB88xTIkP3ichqhJMk1y7REG3Im8l5If3hfi1g5bPcckDXzhe3

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: roleenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.roleenum AS ENUM (
    'Admin',
    'FleetManager',
    'Driver',
    'Dispatcher'
);


ALTER TYPE public.roleenum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_logs (
    activity_id uuid NOT NULL,
    user_id uuid,
    action character varying NOT NULL,
    entity_type character varying,
    entity_id character varying,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.activity_logs OWNER TO postgres;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    attendance_id uuid NOT NULL,
    driver_id uuid NOT NULL,
    check_in timestamp without time zone,
    check_out timestamp without time zone,
    status character varying NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: drivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drivers (
    driver_id uuid NOT NULL,
    user_id uuid,
    name character varying NOT NULL,
    phone character varying NOT NULL,
    license_number character varying NOT NULL,
    status character varying,
    created_at timestamp without time zone,
    vehicle_id uuid
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- Name: email_otps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_otps (
    email character varying(100) NOT NULL,
    otp character varying(6) NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.email_otps OWNER TO postgres;

--
-- Name: fuel_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fuel_records (
    fuel_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    fuel_amount double precision NOT NULL,
    fuel_cost double precision NOT NULL,
    fuel_station character varying NOT NULL,
    filled_by character varying,
    fuel_date timestamp without time zone,
    mileage double precision,
    refill_date timestamp without time zone
);


ALTER TABLE public.fuel_records OWNER TO postgres;

--
-- Name: gps_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gps_tracking (
    tracking_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    speed double precision,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.gps_tracking OWNER TO postgres;

--
-- Name: job_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_runs (
    run_id uuid NOT NULL,
    task_name character varying(150) NOT NULL,
    started_at timestamp without time zone NOT NULL,
    finished_at timestamp without time zone,
    success boolean,
    result text,
    error text
);


ALTER TABLE public.job_runs OWNER TO postgres;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leave_requests (
    leave_id uuid NOT NULL,
    driver_id uuid NOT NULL,
    leave_date date NOT NULL,
    reason text,
    status character varying NOT NULL,
    reviewed_by uuid,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.leave_requests OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id uuid NOT NULL,
    user_id uuid,
    title character varying NOT NULL,
    message character varying NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    type character varying DEFAULT 'info'::character varying NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: shipment_status_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipment_status_history (
    history_id uuid NOT NULL,
    shipment_id uuid NOT NULL,
    status character varying NOT NULL,
    changed_at timestamp without time zone NOT NULL,
    changed_by_user_id uuid
);


ALTER TABLE public.shipment_status_history OWNER TO postgres;

--
-- Name: shipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipments (
    shipment_id uuid NOT NULL,
    vehicle_id uuid,
    driver_id uuid,
    tracking_number character varying NOT NULL,
    source character varying NOT NULL,
    destination character varying NOT NULL,
    status character varying,
    eta character varying,
    created_at timestamp without time zone,
    customer_name character varying,
    shipment_weight double precision,
    expected_delivery_at timestamp without time zone
);


ALTER TABLE public.shipments OWNER TO postgres;

--
-- Name: trips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trips (
    trip_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    driver_id uuid NOT NULL,
    shipment_id uuid NOT NULL,
    start_location character varying NOT NULL,
    end_location character varying NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    status character varying,
    distance_km double precision,
    actual_distance_km double precision,
    duration_minutes integer,
    route_type character varying,
    eta timestamp without time zone,
    remaining_distance_km double precision
);


ALTER TABLE public.trips OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(15),
    role public.roleenum NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    email_verified boolean DEFAULT false NOT NULL,
    verification_code character varying(6),
    verification_code_expires_at timestamp without time zone,
    address character varying(255),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('Admin'::character varying)::text, ('FleetManager'::character varying)::text, ('Driver'::character varying)::text, ('Dispatcher'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: vehicle_maintenance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicle_maintenance (
    maintenance_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    service_type character varying NOT NULL,
    description character varying,
    service_date timestamp without time zone,
    next_service_date timestamp without time zone,
    cost double precision,
    status character varying
);


ALTER TABLE public.vehicle_maintenance OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    vehicle_id uuid NOT NULL,
    registration_number character varying NOT NULL,
    vehicle_type character varying NOT NULL,
    capacity character varying NOT NULL,
    fuel_type character varying NOT NULL,
    status character varying,
    created_at timestamp without time zone,
    brand character varying,
    model character varying,
    manufacture_year integer,
    assigned_driver_id uuid
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_logs (activity_id, user_id, action, entity_type, entity_id, created_at) FROM stdin;
24e655cc-6067-4a43-a03a-1007b12dae86	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.updated	vehicle	e8730316-9126-485f-9dac-ceca230b2ab3	2026-08-28 04:43:59.175028
84b1a3c5-c8a9-4fa4-b61d-8ae24a396a87	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.created	vehicle	80fc44dd-b051-4b5d-ba6c-db1c9cc5953f	2026-08-28 04:46:06.929715
d59e6409-d460-4876-9116-12eb3fd83aef	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.created	vehicle	97f9f879-0468-480c-bc9c-c38d79d004fd	2026-08-28 04:53:41.616506
180151cb-f06d-4ce8-9987-7742e7bdf7b5	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.created	vehicle	9c23be6e-e1e4-48d3-b8d2-76be0456af32	2026-08-28 04:54:40.379585
eccf5489-827a-4faf-867b-77bcc36461f9	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.updated	vehicle	80fc44dd-b051-4b5d-ba6c-db1c9cc5953f	2026-08-28 04:54:48.669049
6972f7d0-3f1d-467e-8a0a-0edfca661dd5	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 04:57:14.828336
04e21d54-b950-41f2-afd8-84ef606a144a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.created	maintenance	68049d4b-f0af-47e4-b43b-63b15e6a5951	2026-08-28 05:29:47.243814
046bfb46-4e56-4e21-bea8-1f9890248033	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.updated	maintenance	f362ccbf-24bf-4e5c-b174-dabf852cd8ce	2026-08-28 05:40:18.598907
28068e56-1e46-486d-b207-6f9e7ac417a9	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-28 05:51:13.548281
c55d494f-84d9-419b-9b1d-15777908523c	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-28 05:51:42.319704
0103d9ca-772c-414e-8787-c4cdcfcd9f0a	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-28 05:52:50.659081
5b455f88-55e3-4e37-a754-82e4f9657358	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-28 05:59:14.262223
f360c9cb-4e3b-4a8c-a5df-f4e4daee910e	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 05:59:35.460589
1339ed9c-1f88-4b62-8cce-b7359b4fe28e	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 12:02:15.419605
87c92a14-e0b5-45a9-86b1-c970c0a8e147	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-28 12:02:28.070075
c4a8056d-1c76-41d4-8286-0ca92a213aa1	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-28 12:02:38.523741
42bc790f-7fe6-45c7-859e-a2f0962387b7	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-28 12:02:50.182598
a3bb86b9-3b10-4cc3-98cf-8f3fe84efd4a	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.created	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:30:24.089042
52d0876f-eee7-41bf-bb7c-30b462f50eac	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:30:36.739221
14b0b7ff-b122-4ef2-b600-630a7d1dbf8b	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:31:07.84504
2987a9e8-7e98-43ad-9a00-2e0e97d18830	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.created	shipment	7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	2026-08-28 12:31:46.103597
65dddd99-84b0-4adc-9992-5929e2db7e04	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:31:54.871344
379f008b-e58b-48ea-be8d-cf028f96aad3	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	2026-08-28 12:32:02.646937
e4a7beb0-df22-4220-9c5e-bf316aa1d4d8	670871bb-6e48-431e-ae05-1b56663c0a7b	trip.created	trip	0d790a49-83f4-4331-a050-db7cfdf27299	2026-08-28 12:40:02.145966
45b9814d-9b39-4db2-91fd-9f3cf2cea785	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:56:23.062878
6d616a08-538d-450b-b9dd-f6b2ea21c609	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	f59304b4-03f0-4db2-b0cd-42c6a37afa79	2026-08-28 12:57:07.998864
01644b15-818c-464b-9032-3e014323d5e9	670871bb-6e48-431e-ae05-1b56663c0a7b	trip.route_recalculated	trip	0d790a49-83f4-4331-a050-db7cfdf27299	2026-08-28 12:57:15.660663
78c08d94-ef6b-44c9-a95b-c2da263aeb4e	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 13:28:00.097739
74235261-49ca-4f8e-952c-d569f1669932	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 13:28:09.672349
d08e0a17-fdc9-4202-8cfd-5316a599e730	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-28 13:28:20.326737
e3e6f32c-3b1a-48ef-ae54-cd2c5e77cac0	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-28 13:28:28.573008
b1108815-063e-411b-8864-766a81b6a95f	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-28 13:28:41.982788
f022a431-f07d-4339-89e1-8b3492b5bab5	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-28 14:28:19.597642
c1984ef6-a002-4080-a198-510491accf9c	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-28 14:45:03.581455
3da36ad9-0a1d-484e-b6e7-a9bb1605a305	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-28 14:45:15.12048
bcd0ee75-b272-4cd5-8c6c-4e3215ba9b76	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-28 14:45:23.912779
0a9feb05-c119-4ce2-9036-00e2941f53f5	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-29 13:04:05.942964
b3878cdd-a61b-4db9-bf02-e706b91f6c8b	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-29 13:05:29.815876
9ea63075-4c27-4ecd-a0d4-4fb923cd54e2	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-29 13:07:09.438241
0c9d664f-7d36-4baa-baaa-52514f2d099d	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-29 13:07:44.813949
75452c19-97ed-414c-8935-134093da31a5	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-08-29 13:11:03.31672
cd56109a-c8f8-4b05-bb20-7aff8912d627	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-29 14:45:34.22339
12e41eb6-b57f-41f7-9928-66c8f9cc0cff	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-29 14:45:47.860108
3063a051-0d96-4cfe-8c62-6be7ca5579cc	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-29 15:39:59.748888
70abd927-dbf4-4e4f-a362-399e036e2e0f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-29 15:47:40.534942
24d29394-ff88-45ba-890f-c8dde5b60bce	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.status_updated	shipment	00394ed2-f0a6-448b-89b3-23642a34160b	2026-08-29 16:12:21.061023
95e70f02-2fc0-4cd7-8356-6641bb2aaa6e	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-29 16:12:32.947222
6d7486c8-fe93-4573-bb06-ec4d347356cd	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-29 16:13:06.895908
b8f5e350-ae31-4988-b899-b91ab3a54c31	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-08-29 16:13:16.079229
5cfb0dda-1995-4c06-8f5a-4f31f204deb9	670871bb-6e48-431e-ae05-1b56663c0a7b	shipment.created	shipment	e32ee02d-a6de-4a58-bfdf-d36c1755c341	2026-08-29 16:15:18.356028
daebf2ab-3724-41c6-b626-d5ba91dec06c	670871bb-6e48-431e-ae05-1b56663c0a7b	trip.created	trip	e0178854-739f-48c7-8403-d4e2fcf5d8ab	2026-08-29 16:15:57.696292
4361aefe-327e-4619-b5f9-c13b927e96ba	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-31 12:15:30.343339
2b988a5b-2bb8-4634-8193-ffa0cc6e4d6c	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-31 12:15:44.131765
3991ab30-2ced-4546-b6a4-7fad81878743	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-31 12:15:54.859665
488696c8-3433-4b52-903c-124510d2f895	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-08-31 12:16:05.203316
df9c168d-0816-4691-a95a-a4731f405efe	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-08-31 12:21:04.987127
e4e294b7-53ec-43fa-a501-e5f777fff73f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-31 14:18:09.05218
064093bb-2879-4e7f-936e-a98dbb5e29e0	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-31 14:18:49.190842
4942f0ca-62cf-4bc7-9753-9f0bd66eaf19	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-08-31 14:18:58.039041
17e3d8c2-8bc9-4494-9c6d-2056c1c5d2f9	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-08-31 14:19:16.121399
d3a9261a-2a2a-4f04-b01c-26959d7bc90f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-08-31 16:33:18.180022
058e6cba-5fc7-4385-8cdc-2d06d8bebaea	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-01 06:22:18.653037
2299ccad-5eb4-4cc1-bc89-ab2b4baa8c7a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-01 14:45:32.673886
90aadf56-052c-444e-82eb-3e771d44cad9	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-09-01 14:45:50.287474
65084f1a-8e3c-4cbd-b520-9ff2e894b7d8	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.updated	maintenance	055480bd-4156-4829-8b88-5aa4b2a8170d	2026-09-01 14:49:30.813184
d0a6a628-e021-4e10-b38f-e937ed787be9	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.updated	maintenance	055480bd-4156-4829-8b88-5aa4b2a8170d	2026-09-01 14:49:32.615061
b9258837-1595-4bf1-b0a6-b980244f5ace	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.updated	vehicle	e8730316-9126-485f-9dac-ceca230b2ab3	2026-09-01 14:50:01.880486
f4eb7599-5159-4714-a621-6ed020a22d5b	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.created	vehicle	69e0ccec-aa38-449a-991b-39bbac7dedcc	2026-09-01 14:51:11.21427
6a72c983-1eb6-4f57-a556-3cf1e82ce8e1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	vehicle.updated	vehicle	97f9f879-0468-480c-bc9c-c38d79d004fd	2026-09-01 14:51:35.383588
6b3d1388-bc5b-45f7-aafc-0afb5504aded	d3faa1bd-5b40-4e14-bd47-227d9f34f689	shipment.created	shipment	9fac4352-290d-402f-ad83-15dce13c9c4c	2026-09-01 14:52:29.366435
ba25ec68-b58e-4b39-b94b-83f0212720e1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.created	trip	ab2a769c-6f11-4f08-b078-ca01b3f08dff	2026-09-01 14:53:23.132536
038a623e-e62c-4f7c-857f-7b8396a8224a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.created	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-01 14:53:48.016566
7e3aa786-c8bf-46ab-a4be-aeeb2c8e7a90	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-09-01 15:21:18.873711
ce26f863-747c-4818-b318-5ef02f6473d7	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-02 12:12:33.256073
d1c6cd46-f73a-4c4e-90ab-b89c27793a43	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-02 12:13:01.821211
d5530b8e-692e-4b47-9c8b-538a71af91ff	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-09-02 12:13:21.558041
5bec1bc8-8293-4707-9aa6-86091b3bccad	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-09-02 12:13:31.513102
1331915e-54aa-4c37-a528-25e4ad1ac414	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-09-02 12:13:47.303243
474cd912-5e1e-48d5-94b7-26f98d0d929c	d3faa1bd-5b40-4e14-bd47-227d9f34f689	shipment.created	shipment	4b97ab02-a476-4f9c-b071-908c2c76605a	2026-09-02 12:15:21.015665
0899d02d-08f0-4a63-8e11-a4c863071b6c	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.created	trip	f98780fe-763c-4cb2-a3fc-e68e0055c30e	2026-09-02 12:18:53.868709
17d5b138-777d-452b-bcc2-c941c0aee45f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-02 14:28:30.604574
ae5d15b9-e6ed-4430-9637-84962e950270	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-02 14:33:13.104331
46588275-8853-4ff5-b2c6-3e9a270ebdbd	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-09-02 14:33:27.320666
bbf5080d-b91e-4e6c-93da-8a10c4e7c106	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-09-02 14:33:38.505988
7a1ab709-19dd-430a-8909-3ce5d42365e0	676cf171-d65a-47bd-bfda-fdcef73439cc	login	user	676cf171-d65a-47bd-bfda-fdcef73439cc	2026-09-02 14:33:54.875964
6c09a346-f189-4ff8-8abb-f329a5210d93	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 14:53:02.340987
a883971d-38ad-438a-8a54-9a57b758dc04	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 14:53:08.556714
e9da58ab-e375-4786-8aa8-820ff7d1d6b5	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 14:53:29.048022
87f67cde-2ecc-4a10-a47a-67ff30aa35b3	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 14:58:56.145464
7e9551ca-0fe5-4a5b-a817-efe5046c8e04	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 15:13:24.340893
6687d276-2960-42a0-b2c3-6a3bfe574b77	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 15:13:45.958108
df688e39-37b2-42e4-9c74-4e60494b8fd4	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	13ff480c-fb98-4b61-be95-901e52a68023	2026-09-02 15:14:46.250195
78e146fc-b299-4e0b-b3e6-6f14079defe6	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-02 15:28:41.943086
198c2bc5-1ebf-4ef9-a5e6-bd05d87da858	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-03 13:04:02.140162
1c097b2b-a95a-4e53-95a6-6bf02d64b3c0	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-03 13:04:50.601709
ba3edf43-4b64-457b-9304-7968fcdf1edb	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	login	user	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	2026-09-03 13:05:50.444234
1d0327ed-39b8-4d2a-bcff-fcefac676f31	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-09-03 13:06:07.90797
f443c82d-3692-4e3f-ba7a-f93480b416dd	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	login	user	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	2026-09-03 14:19:45.733083
52b26658-dabd-472f-bbe4-21cc1b8ce37f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-03 15:30:36.120943
284c01dd-1f54-4a60-99c8-1c2bb877a597	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-05 13:05:13.362605
f2fc3df0-dc3d-4a97-bc32-d05d9ef76eb4	d3faa1bd-5b40-4e14-bd47-227d9f34f689	shipment.status_updated	shipment	4b97ab02-a476-4f9c-b071-908c2c76605a	2026-09-05 13:10:15.875298
db8c0eef-898d-4d1e-be2d-9035ecd298ca	d3faa1bd-5b40-4e14-bd47-227d9f34f689	shipment.created	shipment	bc9337c5-249f-47f0-8f6e-183f332c0e99	2026-09-05 13:11:43.339426
2bc820be-5517-4f39-83b5-4ef936a4d3fd	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.updated	maintenance	68049d4b-f0af-47e4-b43b-63b15e6a5951	2026-09-05 13:12:17.345676
3ce34118-87ff-4a5f-91e7-ff54ce179f5d	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.updated	maintenance	68049d4b-f0af-47e4-b43b-63b15e6a5951	2026-09-05 13:12:19.666213
3ca8d8c5-b82d-4910-9e32-8b4e3d12a628	d3faa1bd-5b40-4e14-bd47-227d9f34f689	maintenance.created	maintenance	233928dc-762b-4ee4-9d1d-e5118cce3545	2026-09-05 13:13:08.035066
c3cbf356-b1d3-47de-ab02-5abd602d1f52	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.created	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-05 13:14:03.171319
7ad8b883-9e6a-4d38-b735-86c6fb156cef	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-05 13:24:45.695436
bd58a1f6-8da5-433b-8c3e-0574c9797550	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-05 13:28:47.24209
12198c3f-c2e8-4ed9-99ca-3f2cefb1bd97	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-05 13:29:05.070071
885647fa-aec4-40f0-8dcc-d6698ca335ac	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-05 13:29:11.451534
a911a749-6fd0-4d8b-a204-61a628ddbecc	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-07 05:40:33.533785
727ae904-65c1-4ee4-bf1d-b9adddf78612	d3faa1bd-5b40-4e14-bd47-227d9f34f689	trip.route_recalculated	trip	2b178a09-ce2c-424a-89fb-5f87d3436539	2026-09-07 05:40:50.069241
c7839980-38b2-4733-90c1-e69fe609e575	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-07 08:31:47.058617
7a3282f5-98f2-4b6e-a3c4-5836f32b0058	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-07 09:48:05.631327
d855c76d-620d-400d-b4c3-35fcfc5ee29e	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-07 14:23:53.535216
24df1a2a-14ab-448d-8e7d-f7ef29031bc1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	login	user	d3faa1bd-5b40-4e14-bd47-227d9f34f689	2026-09-07 14:24:15.182835
b7996954-4f8e-42a9-a7b9-be608a3964f8	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-07 14:24:46.838224
835a67e4-ac49-4355-92af-ee725872921d	670871bb-6e48-431e-ae05-1b56663c0a7b	maintenance.updated	maintenance	233928dc-762b-4ee4-9d1d-e5118cce3545	2026-09-07 14:25:07.517206
12e195d5-a456-4338-a53a-3f15f0665971	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-08 05:38:37.376111
4d44aa1b-7e25-41ee-95d2-e885ff9dfe87	670871bb-6e48-431e-ae05-1b56663c0a7b	login	user	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-09-08 08:46:28.940451
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
a2c7e1c4d9f0
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (attendance_id, driver_id, check_in, check_out, status, date) FROM stdin;
ffe1ee05-68d7-455c-9d98-6837ff68a392	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	2026-08-01 09:00:00	\N	Present	2026-08-01
64156204-680e-4206-8c59-22ed55204e38	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-08-14 20:12:00	\N	Present	2026-08-14
fa17031c-fca1-4387-82d1-5768e1b72b92	45243140-5694-434e-816f-6bc238986524	2026-08-28 00:00:00	\N	Present	2026-08-28
f271d2cf-65bf-4836-8dc0-a3111bf76bee	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-08-28 00:00:00	\N	Present	2026-08-28
ae654872-e4ca-40a0-82f4-38e42893acc7	3c4164d3-133e-4711-93db-115ad295478e	2026-08-29 00:00:00	\N	Present	2026-08-29
6c86c8b9-b1f7-43a3-926f-90ef182508d7	45243140-5694-434e-816f-6bc238986524	2026-08-31 00:00:00	\N	Leave	2026-08-31
e3c8ff62-5dff-400a-b33a-fefce80b0084	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	2026-08-31 00:00:00	\N	Present	2026-08-31
bc78670d-e90b-4c01-a245-b973f49831d1	3c4164d3-133e-4711-93db-115ad295478e	2026-08-31 00:00:00	\N	Present	2026-08-31
1c263ecd-e2c1-4292-ac48-6547f00e9e37	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-08-31 00:00:00	\N	Present	2026-08-31
9f1148a1-f8cf-4047-8824-f3139f113a20	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	2026-09-01 00:00:00	\N	Present	2026-09-01
93e88be7-4d99-4e00-8e63-f0388bd8911a	45243140-5694-434e-816f-6bc238986524	2026-09-01 00:00:00	\N	Present	2026-09-01
c398745a-da6c-451a-933c-7c787759ec04	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-09-01 00:00:00	\N	Present	2026-09-01
fc2a3aff-f97d-4683-8697-765cb697c448	3c4164d3-133e-4711-93db-115ad295478e	2026-09-01 00:00:00	\N	Present	2026-09-01
90068f76-c6b9-4737-b119-53d35a4b573e	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	2026-09-01 00:00:00	\N	Present	2026-09-01
a274b6d7-3b14-4f45-bb5f-96c53cb31ced	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	2026-09-01 00:00:00	\N	Present	2026-09-01
623b297d-b406-4b21-a19d-7fd105f55bde	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	2026-09-02 00:00:00	\N	Present	2026-09-02
ddef4e23-7ad5-48f6-9a71-25c7a9b84729	3c4164d3-133e-4711-93db-115ad295478e	2026-09-02 00:00:00	\N	Present	2026-09-02
8af479d3-409f-4b66-bd20-4c2f6e8d0f75	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	2026-09-03 00:00:00	\N	Leave	2026-09-03
df9ded3d-ce6e-4dcf-8082-868c4b4f5dc3	3c4164d3-133e-4711-93db-115ad295478e	2026-09-03 00:00:00	\N	Present	2026-09-03
108a21eb-5af1-4252-a729-cbfbc7b5a60c	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-09-03 00:00:00	\N	Present	2026-09-03
9344002b-e453-4a86-92a9-ca3f281d7365	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	2026-09-03 00:00:00	\N	Absent	2026-09-03
11c72f59-2e5d-413d-bb89-8f49ef05a1ad	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	2026-09-03 00:00:00	\N	Present	2026-09-03
d4d1324f-c354-43e5-b234-ed83c156496d	45243140-5694-434e-816f-6bc238986524	2026-09-03 00:00:00	\N	Present	2026-09-03
56345c12-e560-43f0-ba72-b0edf88a38fc	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	2026-09-05 00:00:00	\N	Present	2026-09-05
8bc42aa4-ac0c-4295-b0cd-2d4fbef9d654	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	2026-09-05 00:00:00	\N	Present	2026-09-05
bbc3d742-ffa2-490a-8921-9526ee61c386	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	2026-09-07 00:00:00	\N	Present	2026-09-07
0eb7e3b2-b8ae-4e81-a60c-e01be8414b41	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	2026-09-07 00:00:00	\N	Present	2026-09-07
eb2e2be6-bbb2-4d55-9d55-82e594337726	3c4164d3-133e-4711-93db-115ad295478e	2026-09-07 00:00:00	\N	Present	2026-09-07
58575c70-146b-4d17-9de5-dba38759da64	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-09-07 00:00:00	\N	Present	2026-09-07
9a9e84c9-8766-40aa-822d-cba2eec85db7	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	2026-09-07 00:00:00	\N	Present	2026-09-07
4433f368-021c-4cb5-8a6b-bbc33ab2f4b8	45243140-5694-434e-816f-6bc238986524	2026-09-07 00:00:00	\N	Present	2026-09-07
\.


--
-- Data for Name: drivers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drivers (driver_id, user_id, name, phone, license_number, status, created_at, vehicle_id) FROM stdin;
b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	\N	Ramesh Kumar	9876543210	AP20260001	Available	2026-08-01 13:26:09.152497	\N
68e44e79-6b17-4117-b72d-b4c1b89ad8c7	\N	Hemanth	7416818182	AP20433001	Available	2026-08-28 04:54:54.558393	9c23be6e-e1e4-48d3-b8d2-76be0456af32
5f141cfc-3848-4337-9e00-59eec4d587a3	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	manohar	8978456290	AP202401563	Available	2026-08-10 17:50:47.909252	b84072f3-0a48-4973-aa6e-b51be31b1b79
3c4164d3-133e-4711-93db-115ad295478e	676cf171-d65a-47bd-bfda-fdcef73439cc	Kiran Reddy	7416818182	AP202401365	Available	2026-08-29 14:44:15.545684	\N
45243140-5694-434e-816f-6bc238986524	\N	Revanth	8639526641	AP987654321	Available	2026-08-27 15:24:55.778506	\N
d97a46a8-c59f-4bbf-8914-cbbc8707ae85	\N	Nagendra 	6304978106	AP20423601	On Trip	2026-08-28 05:28:13.491763	\N
\.


--
-- Data for Name: email_otps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_otps (email, otp, expires_at) FROM stdin;
dhani8639@gmail.com	874454	2026-08-05 14:45:05.860083
reddydhani@gmail.com	244410	2026-08-05 15:14:15.189753
dhanireddyrevanth.aiml@sandipuniversity.edu.in	562930	2026-08-06 11:44:50.025637
tejat9296@gmail.com	649249	2026-08-06 12:14:47.968541
vennapusauday.aiml@sandipuniversity.edi.in	894810	2026-08-26 15:23:57.019338
\.


--
-- Data for Name: fuel_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fuel_records (fuel_id, vehicle_id, fuel_amount, fuel_cost, fuel_station, filled_by, fuel_date, mileage, refill_date) FROM stdin;
cb810435-4e34-4f24-b0e7-503e5f41c42b	b84072f3-0a48-4973-aa6e-b51be31b1b79	35	3500	near kadapa	manohar	2026-08-26 18:56:00	\N	\N
7aec8c4f-9cef-48ff-b945-3e188d90111c	b84072f3-0a48-4973-aa6e-b51be31b1b79	380	38000	NA	\N	2026-08-12 21:12:00	\N	\N
0a1a98f9-fe8a-4dea-a5c2-b11aa8823753	b84072f3-0a48-4973-aa6e-b51be31b1b79	225	22500	NA	\N	2026-08-31 17:50:00	\N	\N
a8565ce4-0a77-4283-80e9-4a4d4e06baff	9c23be6e-e1e4-48d3-b8d2-76be0456af32	120	12000	NA	Kiran Reddy	2026-08-31 19:50:00	\N	\N
0dcb8e53-2aad-4f11-8699-4714699994c3	80fc44dd-b051-4b5d-ba6c-db1c9cc5953f	125	12500	Allagadda	manohar	2026-08-29 21:11:00	\N	\N
0317fa27-0613-46bd-976b-cea51452d61a	e8730316-9126-485f-9dac-ceca230b2ab3	265	26500	Badvel	Hemanth	2026-09-01 20:50:00	\N	\N
\.


--
-- Data for Name: gps_tracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gps_tracking (tracking_id, vehicle_id, latitude, longitude, speed, "timestamp") FROM stdin;
d27ae412-649f-4476-ad33-4f5a8599a2c7	b84072f3-0a48-4973-aa6e-b51be31b1b79	17.385	78.4867	45.5	2026-08-01 11:13:56.570883
\.


--
-- Data for Name: job_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_runs (run_id, task_name, started_at, finished_at, success, result, error) FROM stdin;
d6a56823-949d-4a37-8f89-7565dfebdde4	check_maintenance_alerts	2026-08-28 06:04:11.913241	2026-08-28 06:04:12.069331	t	Checked 3 record(s); created 7 alert(s)	\N
8a82ca64-7eeb-4c55-af6a-1f52a7b04ae4	check_delayed_shipments	2026-08-28 06:04:12.761384	2026-08-28 06:04:12.855431	t	Checked shipments - 0 marked Delayed	\N
dafd7c72-7b31-4198-b9b3-60a695054868	check_delayed_shipments	2026-08-28 06:20:00.024715	2026-08-28 06:20:00.126687	t	Checked shipments - 0 marked Delayed	\N
2574ed3d-c8f5-41b1-b711-e4aa26016089	check_delayed_shipments	2026-08-28 06:30:00.018431	2026-08-28 06:30:00.042819	t	Checked shipments - 0 marked Delayed	\N
d279c499-82d4-484c-8759-8449b26eb254	check_delayed_shipments	2026-08-28 06:40:01.022729	2026-08-28 06:40:01.033835	t	Checked shipments - 0 marked Delayed	\N
c39e35f8-1b33-4424-bb28-2046c70e18cb	check_delayed_shipments	2026-08-28 12:04:47.358768	2026-08-28 12:04:47.377225	t	Checked shipments - 0 marked Delayed	\N
ad2de807-095a-46e5-84f8-1769a55b6999	check_maintenance_alerts	2026-08-28 12:04:47.359554	2026-08-28 12:04:47.604552	t	Checked 3 record(s); created 4 alert(s)	\N
2c2d12e4-1f91-4823-be4a-e5a0553980b3	check_delayed_shipments	2026-08-28 12:10:00.107016	2026-08-28 12:10:00.219598	t	Checked shipments - 0 marked Delayed	\N
e1f8f542-1c19-4bc7-ba4f-4815a2d53871	check_delayed_shipments	2026-08-28 12:20:00.033606	2026-08-28 12:20:00.070919	t	Checked shipments - 0 marked Delayed	\N
fa9c3d93-4c36-4943-a506-7f1a775e645c	check_delayed_shipments	2026-08-28 12:30:00.036218	2026-08-28 12:30:00.065353	t	Checked shipments - 0 marked Delayed	\N
89ca829a-6527-4176-a5e0-2b8f255b8692	check_delayed_shipments	2026-08-28 12:40:00.04135	2026-08-28 12:40:00.179527	t	Checked shipments - 0 marked Delayed	\N
9f2242b8-6fb1-4129-9878-44fb53db3d7f	check_delayed_shipments	2026-08-28 12:50:00.05494	2026-08-28 12:50:00.077184	t	Checked shipments - 0 marked Delayed	\N
bd095b1c-3444-4be9-ae78-1be06ec9cff1	check_maintenance_alerts	2026-08-28 13:00:00.038669	2026-08-28 13:00:00.127494	t	Checked 3 record(s); created 1 alert(s)	\N
30513738-085d-4924-a16e-1befd61b939a	check_delayed_shipments	2026-08-28 13:00:00.044684	2026-08-28 13:00:00.19563	t	Checked shipments - 0 marked Delayed	\N
8bdd8dc1-243a-4591-9d6a-34d538fcfa13	check_delayed_shipments	2026-08-28 13:10:00.033353	2026-08-28 13:10:00.059198	t	Checked shipments - 0 marked Delayed	\N
319971fb-c189-4df8-9f6e-4ccc61d52a51	check_delayed_shipments	2026-08-28 13:20:00.040252	2026-08-28 13:20:00.106502	t	Checked shipments - 0 marked Delayed	\N
839e12c4-f9bf-42ef-83d0-932ec7aaefde	check_delayed_shipments	2026-08-28 14:26:16.29905	2026-08-28 14:26:16.521859	t	Checked shipments - 0 marked Delayed	\N
ebde7912-f1dd-4526-a919-17d5dbe88681	check_maintenance_alerts	2026-08-28 14:26:16.308827	2026-08-28 14:26:16.772686	t	Checked 3 record(s); created 0 alert(s)	\N
2bed3f12-1c66-4ff1-88d1-3436698b3261	check_delayed_shipments	2026-08-28 14:30:00.142321	2026-08-28 14:30:00.153206	t	Checked shipments - 0 marked Delayed	\N
0ba4dac4-299f-4acd-83e2-836173693450	check_delayed_shipments	2026-08-28 14:40:00.018688	2026-08-28 14:40:00.038414	t	Checked shipments - 0 marked Delayed	\N
2802aeed-7111-4014-a0c4-64bbeff734a6	check_delayed_shipments	2026-08-28 14:50:00.012598	2026-08-28 14:50:00.099954	t	Checked shipments - 0 marked Delayed	\N
605ecac0-8cf3-417f-aaeb-674ba3013f3e	check_delayed_shipments	2026-08-28 15:00:00.048795	2026-08-28 15:00:00.104466	t	Checked shipments - 0 marked Delayed	\N
d52e4970-897b-4ef9-a234-043198539bc8	check_maintenance_alerts	2026-08-28 15:00:00.0309	2026-08-28 15:00:00.148273	t	Checked 3 record(s); created 0 alert(s)	\N
fe6e9305-cbdd-4d55-8c3b-3dc840a36d71	check_delayed_shipments	2026-08-28 15:10:00.004391	2026-08-28 15:10:00.145847	t	Checked shipments - 0 marked Delayed	\N
22d124ac-a64f-46f8-a94f-a316b4fa12d2	check_delayed_shipments	2026-08-28 15:20:00.003341	2026-08-28 15:20:00.013867	t	Checked shipments - 0 marked Delayed	\N
cc66fa7b-772d-4849-a709-0f821b55394d	check_delayed_shipments	2026-08-28 15:30:00.009107	2026-08-28 15:30:00.031958	t	Checked shipments - 0 marked Delayed	\N
be65afdb-e8b3-4779-b3ce-a832ec4e979e	check_delayed_shipments	2026-08-28 15:40:00.006333	2026-08-28 15:40:00.033228	t	Checked shipments - 0 marked Delayed	\N
946ec4db-7dc6-4ef4-afbd-fb2aea4769d2	check_delayed_shipments	2026-08-28 15:50:00.005946	2026-08-28 15:50:00.028911	t	Checked shipments - 0 marked Delayed	\N
839beafb-8a41-472d-a251-c21eb42f7a7e	check_delayed_shipments	2026-08-29 05:07:21.175271	2026-08-29 05:07:21.196354	t	Checked shipments - 0 marked Delayed	\N
37f8cf0f-70bf-4b11-916c-d3a3ee790012	check_maintenance_alerts	2026-08-29 05:07:21.294111	2026-08-29 05:07:21.485535	t	Checked 3 record(s); created 0 alert(s)	\N
b92ac3e6-5fba-48e8-80b2-677caf8a4398	check_delayed_shipments	2026-08-29 05:10:00.032443	2026-08-29 05:10:00.064404	t	Checked shipments - 0 marked Delayed	\N
f3264541-3432-45b8-aeb5-414b2c675f76	check_delayed_shipments	2026-08-29 08:04:38.963534	2026-08-29 08:04:39.11589	t	Checked shipments - 0 marked Delayed	\N
9c7c6c3c-ffbf-4515-b14b-96f5e38221ab	check_maintenance_alerts	2026-08-29 08:04:38.968745	2026-08-29 08:04:39.257377	t	Checked 3 record(s); created 0 alert(s)	\N
e1e36992-1d08-42be-a99f-101d5f9262bf	check_delayed_shipments	2026-08-29 08:10:00.007922	2026-08-29 08:10:00.042431	t	Checked shipments - 0 marked Delayed	\N
0b9f1ed6-d83e-497a-9764-a5aea27b0b41	check_delayed_shipments	2026-08-29 08:20:00.044595	2026-08-29 08:20:00.060275	t	Checked shipments - 0 marked Delayed	\N
01e1ed41-9a8c-4c04-972c-061a6b003736	check_delayed_shipments	2026-08-29 08:30:00.023082	2026-08-29 08:30:00.057047	t	Checked shipments - 0 marked Delayed	\N
fa93a395-97fc-4c1c-9df5-cdc19ddb7fca	check_delayed_shipments	2026-08-29 08:40:00.035787	2026-08-29 08:40:00.055148	t	Checked shipments - 0 marked Delayed	\N
34d0873f-8fb7-4a31-9908-4ac2e3b512d7	check_delayed_shipments	2026-08-29 08:50:00.047795	2026-08-29 08:50:00.104714	t	Checked shipments - 0 marked Delayed	\N
ea2e443d-7377-49e7-b798-91c44cc4a551	check_maintenance_alerts	2026-08-29 09:00:00.09079	2026-08-29 09:00:00.260397	t	Checked 3 record(s); created 0 alert(s)	\N
e0605a09-ccc1-4975-8603-2baafc5d36ce	check_delayed_shipments	2026-08-29 09:00:00.153524	2026-08-29 09:00:00.315996	t	Checked shipments - 0 marked Delayed	\N
5c1a6d21-7176-4051-ae43-9bbe4d7805dc	check_delayed_shipments	2026-08-29 09:10:00.014084	2026-08-29 09:10:00.061956	t	Checked shipments - 0 marked Delayed	\N
234cad1b-a025-4e0d-97cf-892fb8313088	check_delayed_shipments	2026-08-29 12:06:23.545199	2026-08-29 12:06:23.567296	t	Checked shipments - 0 marked Delayed	\N
a9067996-3f4c-4691-a3ed-b4e44bca84e2	check_maintenance_alerts	2026-08-29 12:06:23.561931	2026-08-29 12:06:23.684407	t	Checked 3 record(s); created 0 alert(s)	\N
f2b9959d-c5e3-4a57-be07-895d8441d060	check_delayed_shipments	2026-08-29 12:10:00.006373	2026-08-29 12:10:00.055923	t	Checked shipments - 0 marked Delayed	\N
147cd932-ce66-431c-b74a-73d0f8b2a9ff	check_delayed_shipments	2026-08-29 12:20:00.027483	2026-08-29 12:20:00.071989	t	Checked shipments - 0 marked Delayed	\N
cc399bd9-0db4-4e4e-b923-79a7754df743	check_delayed_shipments	2026-08-29 12:30:00.01614	2026-08-29 12:30:00.050309	t	Checked shipments - 0 marked Delayed	\N
1abd535b-694e-4cb5-b723-49b26c18fc6c	check_delayed_shipments	2026-08-29 12:40:00.014521	2026-08-29 12:40:00.049408	t	Checked shipments - 0 marked Delayed	\N
97be07a4-cc23-4e53-839f-d5b9f4bbf10a	check_delayed_shipments	2026-08-29 12:50:00.006832	2026-08-29 12:50:00.030992	t	Checked shipments - 0 marked Delayed	\N
6681a3b3-9ee1-4b52-8f0f-0159b2f5f2d4	check_maintenance_alerts	2026-08-29 13:00:00.048785	2026-08-29 13:00:00.097268	t	Checked 3 record(s); created 0 alert(s)	\N
de04983c-3d88-4ffe-a4c7-bf9b9fe092cc	check_delayed_shipments	2026-08-29 13:00:00.073573	2026-08-29 13:00:00.133168	t	Checked shipments - 0 marked Delayed	\N
166d24a7-fec4-4e96-a98d-5066ddff77db	check_delayed_shipments	2026-08-29 13:10:00.009297	2026-08-29 13:10:00.05208	t	Checked shipments - 0 marked Delayed	\N
274d51d1-ac39-4831-8698-5248b692f81b	check_delayed_shipments	2026-08-29 13:20:00.118339	2026-08-29 13:20:00.465993	t	Checked shipments - 0 marked Delayed	\N
ccde4562-d8aa-491c-a8f0-d4a1ada17f52	check_delayed_shipments	2026-08-29 13:30:00.013581	2026-08-29 13:30:00.273769	t	Checked shipments - 0 marked Delayed	\N
acafb88d-7284-4e6d-b259-ca333da689fb	check_delayed_shipments	2026-08-29 14:50:00.064933	2026-08-29 14:50:00.172901	t	Checked shipments - 0 marked Delayed	\N
42fbbbe5-035b-4802-9dd9-101360190dfd	check_maintenance_alerts	2026-08-29 15:00:00.010847	2026-08-29 15:00:00.087186	t	Checked 3 record(s); created 0 alert(s)	\N
14ed0a6f-cc90-4ea2-ac1c-56c977aa4bb1	check_delayed_shipments	2026-08-29 15:00:00.014909	2026-08-29 15:00:00.146375	t	Checked shipments - 0 marked Delayed	\N
06a53213-2783-48ce-ade5-f4ab3a77d471	check_delayed_shipments	2026-08-29 15:10:00.007305	2026-08-29 15:10:00.046395	t	Checked shipments - 0 marked Delayed	\N
402e9a5d-02e1-4a19-90b0-9b14a81e5fb4	check_delayed_shipments	2026-08-29 15:20:00.013507	2026-08-29 15:20:00.054194	t	Checked shipments - 0 marked Delayed	\N
72dfa142-79c6-466f-b05c-ec834fc0ff3e	check_delayed_shipments	2026-08-29 15:30:00.008271	2026-08-29 15:30:00.036324	t	Checked shipments - 0 marked Delayed	\N
83f3e841-f0de-4fd6-8ee4-89bff91109a9	check_delayed_shipments	2026-08-29 15:40:00.091826	2026-08-29 15:40:00.101209	t	Checked shipments - 0 marked Delayed	\N
a677b401-d715-4ada-9e1a-56927eff8797	check_delayed_shipments	2026-08-29 15:50:00.005074	2026-08-29 15:50:00.054542	t	Checked shipments - 0 marked Delayed	\N
34a0b42b-63e9-49f0-83cd-5ac99741eb2e	check_delayed_shipments	2026-08-29 16:00:00.06539	2026-08-29 16:00:00.209153	t	Checked shipments - 0 marked Delayed	\N
a8b24013-bcf9-45dd-a89c-9dc69bf15211	check_maintenance_alerts	2026-08-30 03:41:36.007477	2026-08-30 03:41:36.270767	t	Checked 3 record(s); created 0 alert(s)	\N
237146a3-0dc4-4c70-8cf4-ef269e861eec	check_maintenance_alerts	2026-08-30 04:00:00.056418	2026-08-30 04:00:00.106548	t	Checked 3 record(s); created 0 alert(s)	\N
2ec682ca-247a-402e-b125-625f5ba3704d	check_maintenance_alerts	2026-08-30 05:00:00.041515	2026-08-30 05:00:00.108581	t	Checked 3 record(s); created 0 alert(s)	\N
d3969ca1-3b46-4640-bb3c-61d7eb0768e8	check_maintenance_alerts	2026-08-29 16:00:00.064864	2026-08-29 16:00:00.237454	t	Checked 3 record(s); created 0 alert(s)	\N
87a42dde-a0e6-4ccb-8c81-969d4d0511c0	check_delayed_shipments	2026-08-29 16:10:00.010605	2026-08-29 16:10:00.042957	t	Checked shipments - 0 marked Delayed	\N
3a844db9-dc8d-4fad-b5cb-21bd859f9c4c	check_delayed_shipments	2026-08-29 16:20:00.009061	2026-08-29 16:20:00.047797	t	Checked shipments - 1 marked Delayed	\N
0ff41b34-bfaa-4f6e-91e7-63dbbcf3ba57	check_delayed_shipments	2026-08-29 16:30:00.005344	2026-08-29 16:30:00.033021	t	Checked shipments - 0 marked Delayed	\N
0824b088-b050-43e2-acff-13d9e3844859	check_delayed_shipments	2026-08-29 16:40:00.010583	2026-08-29 16:40:00.034963	t	Checked shipments - 0 marked Delayed	\N
ad43beb6-d732-4747-acaa-ccb54d9968ae	check_delayed_shipments	2026-08-29 16:50:00.051317	2026-08-29 16:50:00.087796	t	Checked shipments - 0 marked Delayed	\N
2d19e3c1-da06-4049-98e0-6eeaf422b47a	check_delayed_shipments	2026-08-30 03:41:35.89471	2026-08-30 03:41:35.911203	t	Checked shipments - 0 marked Delayed	\N
7ee22a00-1a56-4463-9fca-54642350a4c9	check_delayed_shipments	2026-08-30 03:50:00.011658	2026-08-30 03:50:00.050693	t	Checked shipments - 0 marked Delayed	\N
851aa98e-5c36-43d0-90e5-5b9cd7a85131	check_delayed_shipments	2026-08-30 04:00:00.044454	2026-08-30 04:00:00.065904	t	Checked shipments - 0 marked Delayed	\N
a493e77e-fc08-4db1-9892-3ab48ba51806	check_delayed_shipments	2026-08-30 04:10:00.008891	2026-08-30 04:10:00.036891	t	Checked shipments - 0 marked Delayed	\N
74c35c1d-4dbc-423e-84a4-acbfbf0a3467	check_delayed_shipments	2026-08-30 04:20:00.014291	2026-08-30 04:20:00.050493	t	Checked shipments - 0 marked Delayed	\N
57545c8e-89c4-4b2e-b7b7-be0822dbf3b2	check_delayed_shipments	2026-08-30 04:30:00.019904	2026-08-30 04:30:00.050137	t	Checked shipments - 0 marked Delayed	\N
af9854db-5481-4c40-9ad7-e538bc5ad415	check_delayed_shipments	2026-08-30 04:40:00.01872	2026-08-30 04:40:00.059723	t	Checked shipments - 0 marked Delayed	\N
7480b335-035d-4372-b0b7-398a27aa9a49	check_delayed_shipments	2026-08-30 04:50:00.00541	2026-08-30 04:50:00.032054	t	Checked shipments - 0 marked Delayed	\N
e6f95c4f-2834-4876-838e-39baa596d408	check_delayed_shipments	2026-08-30 05:00:00.00478	2026-08-30 05:00:00.035808	t	Checked shipments - 0 marked Delayed	\N
dca485ba-347b-4416-81ee-4674df66e928	check_delayed_shipments	2026-08-30 05:10:00.011203	2026-08-30 05:10:00.033754	t	Checked shipments - 0 marked Delayed	\N
26172299-5913-4a83-aeae-2faaea095c73	check_delayed_shipments	2026-08-30 05:20:00.009089	2026-08-30 05:20:00.031881	t	Checked shipments - 0 marked Delayed	\N
78b93a83-715a-41eb-924c-ff01e728f490	check_delayed_shipments	2026-08-30 05:30:05.793368	2026-08-30 05:30:05.814363	t	Checked shipments - 0 marked Delayed	\N
768fbb5b-a0dc-4e57-a7f9-d8c5a754c171	check_delayed_shipments	2026-08-30 05:40:00.013595	2026-08-30 05:40:00.057059	t	Checked shipments - 0 marked Delayed	\N
6e0cafea-80c9-4f03-8cc0-e041406e7144	check_delayed_shipments	2026-08-30 05:50:00.008064	2026-08-30 05:50:00.044272	t	Checked shipments - 0 marked Delayed	\N
7cec4dc1-d24e-4cd6-8ce8-be04554689d4	check_delayed_shipments	2026-08-30 06:00:00.004243	2026-08-30 06:00:00.044007	t	Checked shipments - 0 marked Delayed	\N
54c6b295-941c-4e9a-a3eb-9adbffa685b3	check_maintenance_alerts	2026-08-30 06:00:00.045653	2026-08-30 06:00:00.155837	t	Checked 3 record(s); created 0 alert(s)	\N
ad7eff0b-5f15-402b-8d59-be0a9f5d8a19	check_delayed_shipments	2026-08-30 06:10:00.01066	2026-08-30 06:10:00.071071	t	Checked shipments - 0 marked Delayed	\N
8ec90e28-c137-4c5c-97ed-cc89a5de3a48	check_delayed_shipments	2026-08-30 06:20:00.126383	2026-08-30 06:20:00.181549	t	Checked shipments - 0 marked Delayed	\N
57e0ae19-4444-4ca8-a06d-4861c2d47fe0	check_delayed_shipments	2026-08-30 06:30:00.12027	2026-08-30 06:30:00.171897	t	Checked shipments - 0 marked Delayed	\N
b7603d6b-431b-4c29-ae76-be226e7159a2	check_delayed_shipments	2026-08-30 06:40:00.007687	2026-08-30 06:40:00.041495	t	Checked shipments - 0 marked Delayed	\N
647fb558-0ad7-47d4-b7c6-d06174c2c0fe	check_delayed_shipments	2026-08-30 06:50:00.005025	2026-08-30 06:50:00.049462	t	Checked shipments - 0 marked Delayed	\N
ad7b9151-f904-4d60-b917-8ff7f84a9529	check_delayed_shipments	2026-08-30 07:00:00.006304	2026-08-30 07:00:00.05594	t	Checked shipments - 0 marked Delayed	\N
6346d16c-9feb-4389-bf3b-d6ead7280ff0	check_maintenance_alerts	2026-08-30 07:00:00.061001	2026-08-30 07:00:00.138799	t	Checked 3 record(s); created 0 alert(s)	\N
245f111c-d58c-41f3-be4f-7408bd7ac724	check_delayed_shipments	2026-08-30 07:10:00.062631	2026-08-30 07:10:00.072473	t	Checked shipments - 0 marked Delayed	\N
d9882fad-d2e7-4c53-936b-240ae13d5ca7	check_delayed_shipments	2026-08-30 15:03:07.102022	2026-08-30 15:03:07.128624	t	Checked shipments - 0 marked Delayed	\N
397cc414-0a10-4f50-bdcc-a796f4055681	check_maintenance_alerts	2026-08-30 15:03:07.101627	2026-08-30 15:03:07.178116	t	Checked 3 record(s); created 4 alert(s)	\N
bf1696b3-fb61-4aca-8714-975a83eeac9d	check_delayed_shipments	2026-08-30 15:10:00.006765	2026-08-30 15:10:00.025415	t	Checked shipments - 0 marked Delayed	\N
04175427-88e6-404d-94fb-5d255d889cd9	check_delayed_shipments	2026-08-30 15:20:00.051599	2026-08-30 15:20:00.065675	t	Checked shipments - 0 marked Delayed	\N
a324d601-8513-4b61-9af8-46782fce7931	check_delayed_shipments	2026-08-30 15:30:10.672643	2026-08-30 15:30:10.685861	t	Checked shipments - 0 marked Delayed	\N
0534d860-379a-4ccf-b236-9d05085d940f	check_delayed_shipments	2026-08-30 15:40:00.068826	2026-08-30 15:40:00.084988	t	Checked shipments - 0 marked Delayed	\N
ada740b5-3cba-448e-856f-993cb5d43477	check_delayed_shipments	2026-08-30 15:50:00.01722	2026-08-30 15:50:00.053578	t	Checked shipments - 0 marked Delayed	\N
cde54283-2919-4bd0-9398-de1987586aa3	check_maintenance_alerts	2026-08-30 16:00:00.043983	2026-08-30 16:00:00.147869	t	Checked 3 record(s); created 0 alert(s)	\N
6e196db8-dc5b-48c4-82ad-2955caa0259c	check_delayed_shipments	2026-08-30 16:00:00.138446	2026-08-30 16:00:00.278645	t	Checked shipments - 0 marked Delayed	\N
d62a722b-42bb-4600-a31e-3ee268153e17	check_delayed_shipments	2026-08-30 16:10:00.009026	2026-08-30 16:10:00.085121	t	Checked shipments - 0 marked Delayed	\N
4bea8d0e-084f-445b-9195-a5a5dd0b2769	check_delayed_shipments	2026-08-30 16:20:00.005436	2026-08-30 16:20:00.067876	t	Checked shipments - 0 marked Delayed	\N
04cb0e4c-996c-4955-b903-80b0d22f93f9	check_delayed_shipments	2026-08-30 16:30:00.006868	2026-08-30 16:30:00.034444	t	Checked shipments - 0 marked Delayed	\N
d8d6e098-66fd-4040-8e7a-9ae1950df39c	check_delayed_shipments	2026-08-31 04:24:32.59527	2026-08-31 04:24:32.614563	t	Checked shipments - 0 marked Delayed	\N
58bcb5f8-202d-4fe0-b795-ba1372170930	check_maintenance_alerts	2026-08-31 04:24:32.667028	2026-08-31 04:24:32.872445	t	Checked 3 record(s); created 0 alert(s)	\N
84a054cc-b8a8-4d35-bbb6-8d56456deaee	check_delayed_shipments	2026-08-31 04:30:00.012366	2026-08-31 04:30:00.053613	t	Checked shipments - 0 marked Delayed	\N
3ff74254-b69f-4adc-b6c4-4f99ecfa3e3c	check_delayed_shipments	2026-08-31 04:40:00.450898	2026-08-31 04:40:00.692717	t	Checked shipments - 0 marked Delayed	\N
731b0356-8088-4c27-87e7-b9c9a9ee8aeb	check_delayed_shipments	2026-08-31 04:50:00.141621	2026-08-31 04:50:00.217369	t	Checked shipments - 0 marked Delayed	\N
19174ec9-5ce1-4edd-aa61-54905b011ad9	check_maintenance_alerts	2026-08-31 05:00:00.056191	2026-08-31 05:00:00.188617	t	Checked 3 record(s); created 0 alert(s)	\N
331990db-8fe2-4240-9f64-e619ff4a9cc5	check_delayed_shipments	2026-08-31 05:00:00.091335	2026-08-31 05:00:00.20532	t	Checked shipments - 0 marked Delayed	\N
1e7bda37-0369-40b2-8f4c-3b03a50a8b8f	check_delayed_shipments	2026-08-31 05:10:00.021251	2026-08-31 05:10:00.049546	t	Checked shipments - 0 marked Delayed	\N
6bb01300-9707-4283-9b61-9a918b3ef878	check_delayed_shipments	2026-08-31 05:20:00.024284	2026-08-31 05:20:00.071908	t	Checked shipments - 0 marked Delayed	\N
b3575807-9ff2-440d-992a-5ef1e8aa6c15	check_delayed_shipments	2026-08-31 05:30:00.013238	2026-08-31 05:30:00.034662	t	Checked shipments - 0 marked Delayed	\N
d2a99ab4-448c-4e7d-85b5-9139833c5b18	check_delayed_shipments	2026-08-31 05:40:00.004281	2026-08-31 05:40:00.043594	t	Checked shipments - 0 marked Delayed	\N
49419b00-5296-4751-a995-379602b84663	check_delayed_shipments	2026-08-31 05:50:00.01383	2026-08-31 05:50:00.04693	t	Checked shipments - 0 marked Delayed	\N
2debfd34-87b9-45c2-9e3d-89edc9fa1dd1	check_delayed_shipments	2026-08-31 06:00:00.02133	2026-08-31 06:00:00.074671	t	Checked shipments - 0 marked Delayed	\N
7ea3504a-52b6-421e-bdf3-dd949727d2da	check_maintenance_alerts	2026-08-31 06:00:00.115025	2026-08-31 06:00:00.238424	t	Checked 3 record(s); created 0 alert(s)	\N
7a30f47f-e09f-4fde-855e-7b0fd8ae905f	check_delayed_shipments	2026-08-31 06:10:00.014401	2026-08-31 06:10:00.049988	t	Checked shipments - 0 marked Delayed	\N
644488ee-e3a5-4e4d-9f48-87f30cf22386	check_delayed_shipments	2026-08-31 06:20:00.008523	2026-08-31 06:20:00.049984	t	Checked shipments - 0 marked Delayed	\N
734d6f40-cd5b-44c9-94aa-918577b0fa72	check_delayed_shipments	2026-08-31 06:30:00.004759	2026-08-31 06:30:00.043637	t	Checked shipments - 0 marked Delayed	\N
ba2ff4f6-85f0-416c-9ace-324da616856e	check_delayed_shipments	2026-08-31 06:40:00.006404	2026-08-31 06:40:00.039366	t	Checked shipments - 0 marked Delayed	\N
4533e6cf-a37e-4877-8f43-1f5b5649104a	check_delayed_shipments	2026-08-31 12:18:51.304645	2026-08-31 12:18:51.356703	t	Checked shipments - 1 marked Delayed	\N
245c5470-a424-4027-8c7f-23b75acf7965	check_maintenance_alerts	2026-08-31 12:18:51.35714	2026-08-31 12:18:51.459861	t	Checked 3 record(s); created 0 alert(s)	\N
44b12b83-4721-4462-8f51-2b0536fcf91f	check_delayed_shipments	2026-08-31 12:20:00.047033	2026-08-31 12:20:00.079539	t	Checked shipments - 0 marked Delayed	\N
d331c0f7-2976-4166-8252-3bdfd0718160	check_delayed_shipments	2026-08-31 12:30:00.043713	2026-08-31 12:30:00.060377	t	Checked shipments - 0 marked Delayed	\N
010bbbf4-5faa-4029-bd95-116bcfa4657f	check_delayed_shipments	2026-08-31 12:40:00.030343	2026-08-31 12:40:00.050289	t	Checked shipments - 0 marked Delayed	\N
b480e374-a631-43c7-8dd1-5a9c6329c845	check_delayed_shipments	2026-08-31 12:50:00.018971	2026-08-31 12:50:00.054106	t	Checked shipments - 0 marked Delayed	\N
c8a87448-bee3-4a03-af95-e80b6d709d16	check_delayed_shipments	2026-08-31 14:15:59.487828	2026-08-31 14:15:59.511609	t	Checked shipments - 0 marked Delayed	\N
2444fad8-8613-4a27-b361-2d313074ae89	check_delayed_shipments	2026-08-31 14:20:00.043613	2026-08-31 14:20:00.069262	t	Checked shipments - 0 marked Delayed	\N
1288fa94-9861-4fbe-ba8c-eedaba16e227	check_delayed_shipments	2026-08-31 14:30:00.008343	2026-08-31 14:30:00.06871	t	Checked shipments - 0 marked Delayed	\N
cb015dae-ba9a-4813-9a04-2e503416f6d8	check_delayed_shipments	2026-08-31 14:40:00.00486	2026-08-31 14:40:00.031289	t	Checked shipments - 0 marked Delayed	\N
c89caa3f-0796-49e9-843f-d8d34558eebe	check_delayed_shipments	2026-08-31 14:50:00.004467	2026-08-31 14:50:00.02846	t	Checked shipments - 0 marked Delayed	\N
c05cb96a-d3bb-42a4-b8f3-43c12d7867ca	check_delayed_shipments	2026-08-31 15:00:00.011501	2026-08-31 15:00:00.040135	t	Checked shipments - 0 marked Delayed	\N
4b754bde-13ea-42f4-bca1-8e4915cbc9c8	check_delayed_shipments	2026-08-31 15:10:00.01144	2026-08-31 15:10:00.050837	t	Checked shipments - 0 marked Delayed	\N
d11c9474-76dc-4436-8bdb-60b08592a272	check_delayed_shipments	2026-08-31 15:20:00.003914	2026-08-31 15:20:00.021816	t	Checked shipments - 0 marked Delayed	\N
00c9c573-7063-473f-9fee-4eef34a69d48	check_delayed_shipments	2026-08-31 15:30:00.032016	2026-08-31 15:30:00.062631	t	Checked shipments - 0 marked Delayed	\N
8d9dd23a-d324-4893-a324-2dc014a427c1	check_maintenance_alerts	2026-08-31 14:15:59.525413	2026-08-31 14:15:59.611815	t	Checked 3 record(s); created 0 alert(s)	\N
1302cad8-65ee-404d-b7a2-e74a6c136c44	check_maintenance_alerts	2026-08-31 15:00:00.046351	2026-08-31 15:00:00.139541	t	Checked 3 record(s); created 0 alert(s)	\N
4e69b10a-2b3f-487c-93f1-dee8aade7a67	check_delayed_shipments	2026-08-31 15:40:00.00601	2026-08-31 15:40:00.065896	t	Checked shipments - 0 marked Delayed	\N
6f3eda2e-e0f6-467c-9d6d-8ce227976c7f	check_delayed_shipments	2026-08-31 15:50:00.007147	2026-08-31 15:50:00.035002	t	Checked shipments - 0 marked Delayed	\N
5a74188a-cb55-483d-9988-bb633b149ab9	check_delayed_shipments	2026-08-31 16:00:00.00578	2026-08-31 16:00:00.048942	t	Checked shipments - 0 marked Delayed	\N
742d9329-8b04-4d9c-a836-5b8aa3b935ef	check_maintenance_alerts	2026-08-31 16:00:00.042463	2026-08-31 16:00:00.165778	t	Checked 3 record(s); created 4 alert(s)	\N
7c3c1cac-3522-4b98-bd4d-56c9ba8dee5a	check_delayed_shipments	2026-08-31 16:10:00.004959	2026-08-31 16:10:00.03249	t	Checked shipments - 0 marked Delayed	\N
5c6d89fa-0f4e-49e0-9e32-a83f5d41ce6f	check_delayed_shipments	2026-08-31 16:20:00.009284	2026-08-31 16:20:00.045583	t	Checked shipments - 0 marked Delayed	\N
73ea3f77-5fbf-4ada-9bba-265f6ec58e87	check_delayed_shipments	2026-08-31 16:30:00.003069	2026-08-31 16:30:00.028581	t	Checked shipments - 0 marked Delayed	\N
ccb6a3ba-561c-4ab1-9ce8-1c7301d01ab9	check_delayed_shipments	2026-08-31 16:40:00.041271	2026-08-31 16:40:00.138901	t	Checked shipments - 0 marked Delayed	\N
7f10d72d-b16e-4dc0-9168-0a52a6ab3a58	check_delayed_shipments	2026-08-31 16:57:12.385795	2026-08-31 16:57:12.407394	t	Checked shipments - 0 marked Delayed	\N
b42562fa-2a1a-45eb-b9b9-d5f913a2669b	check_maintenance_alerts	2026-08-31 17:00:00.01867	2026-08-31 17:00:00.102161	t	Checked 3 record(s); created 0 alert(s)	\N
06e28db1-3766-42e3-867a-6190cd3f7a1b	check_delayed_shipments	2026-08-31 17:00:00.051932	2026-08-31 17:00:00.275379	t	Checked shipments - 0 marked Delayed	\N
4e7059a9-2d31-4638-9c8c-2a605787a3c3	check_delayed_shipments	2026-08-31 17:10:00.02437	2026-08-31 17:10:00.052797	t	Checked shipments - 0 marked Delayed	\N
ac462f18-1ba1-4850-8a22-c75ff58c120f	check_delayed_shipments	2026-08-31 17:20:00.009108	2026-08-31 17:20:00.068459	t	Checked shipments - 0 marked Delayed	\N
8fbd7803-0e8f-4fab-97bb-c3ff4fe3b7f9	check_delayed_shipments	2026-08-31 17:30:00.035815	2026-08-31 17:30:00.059107	t	Checked shipments - 0 marked Delayed	\N
80e85825-9179-4fa4-b543-ad521a452ea4	check_delayed_shipments	2026-09-01 05:52:30.099242	2026-09-01 05:52:30.125171	t	Checked shipments - 0 marked Delayed	\N
3bd82b28-3bae-4efd-a003-9587c163821b	check_maintenance_alerts	2026-09-01 05:52:30.225264	2026-09-01 05:52:30.44804	t	Checked 3 record(s); created 7 alert(s)	\N
abafca57-0fd8-4e46-815f-6bd23f836b12	check_delayed_shipments	2026-09-01 06:00:00.059917	2026-09-01 06:00:00.109307	t	Checked shipments - 0 marked Delayed	\N
4904907d-db1d-46dd-b6d6-bd2c7dc08d95	check_maintenance_alerts	2026-09-01 06:00:00.055856	2026-09-01 06:00:00.155403	t	Checked 3 record(s); created 0 alert(s)	\N
26e81b03-1288-4249-b304-db7eff51b824	check_delayed_shipments	2026-09-01 06:10:00.40816	2026-09-01 06:10:00.459822	t	Checked shipments - 0 marked Delayed	\N
eb5e3e24-512a-4b9a-ac33-5b01a7afc078	check_delayed_shipments	2026-09-01 06:20:00.026447	2026-09-01 06:20:00.067527	t	Checked shipments - 0 marked Delayed	\N
ceb366c3-c381-4143-be93-caa6e2391d04	check_delayed_shipments	2026-09-01 06:30:00.054587	2026-09-01 06:30:00.104659	t	Checked shipments - 0 marked Delayed	\N
490f2b93-3b8f-450a-8303-b3bafe9dd9e1	check_delayed_shipments	2026-09-01 06:42:46.586823	2026-09-01 06:42:46.624648	t	Checked shipments - 0 marked Delayed	\N
a35b79a3-163c-4c49-96c3-38c2910780b9	check_delayed_shipments	2026-09-05 13:10:00.035212	2026-09-05 13:10:00.309342	t	Checked shipments - 1 marked Delayed	\N
7827b0d1-d819-4130-9ebb-225b948b74b7	check_delayed_shipments	2026-09-05 13:20:00.012224	2026-09-05 13:20:00.034943	t	Checked shipments - 0 marked Delayed	\N
cf16fb35-e3b4-4c57-9bf1-4cbd7567582d	check_delayed_shipments	2026-09-05 13:30:00.010712	2026-09-05 13:30:00.039733	t	Checked shipments - 0 marked Delayed	\N
6a88e025-7769-421d-9800-e6d80dd4870e	check_delayed_shipments	2026-09-05 14:29:58.901678	2026-09-05 14:29:58.919979	t	Checked shipments - 0 marked Delayed	\N
ff48b63c-826f-4800-910e-dfc1206beea6	check_maintenance_alerts	2026-09-05 14:29:58.931723	2026-09-05 14:29:59.207413	t	Checked 4 record(s); created 0 alert(s)	\N
db91d794-f3b3-43a8-8b09-428a4d5fdf8c	check_delayed_shipments	2026-09-05 14:30:00.005111	2026-09-05 14:30:00.026989	t	Checked shipments - 0 marked Delayed	\N
a882cfba-bbf9-4ee5-a869-4be24f919f15	check_delayed_shipments	2026-09-05 14:40:00.010392	2026-09-05 14:40:00.027382	t	Checked shipments - 0 marked Delayed	\N
f850a919-1747-4058-99bb-3df6b7fea305	check_delayed_shipments	2026-09-05 14:50:00.045423	2026-09-05 14:50:00.057027	t	Checked shipments - 0 marked Delayed	\N
8d5eddef-5811-4732-be26-ea926cfb7548	check_delayed_shipments	2026-09-05 15:00:00.004357	2026-09-05 15:00:00.050325	t	Checked shipments - 0 marked Delayed	\N
216099fc-84db-4599-8b10-9fe098d3260f	check_maintenance_alerts	2026-09-05 15:00:00.03462	2026-09-05 15:00:00.120402	t	Checked 4 record(s); created 0 alert(s)	\N
e662fc80-12ad-4359-9d5e-5aed492560dc	check_delayed_shipments	2026-09-05 15:10:00.007854	2026-09-05 15:10:00.040794	t	Checked shipments - 0 marked Delayed	\N
d78965a5-ffd7-475d-b42f-3006937fd208	check_delayed_shipments	2026-09-05 15:20:00.004555	2026-09-05 15:20:00.033579	t	Checked shipments - 0 marked Delayed	\N
ad493468-8953-4180-98fc-399f43602f05	check_delayed_shipments	2026-09-05 15:30:00.017562	2026-09-05 15:30:00.049196	t	Checked shipments - 0 marked Delayed	\N
f40836dd-a8ab-49ff-94b3-c12023b66e73	check_delayed_shipments	2026-09-05 15:40:00.023535	2026-09-05 15:40:00.04955	t	Checked shipments - 0 marked Delayed	\N
63dc80f3-0934-47b9-9033-fd0816532780	check_delayed_shipments	2026-09-05 15:50:00.007341	2026-09-05 15:50:00.040703	t	Checked shipments - 0 marked Delayed	\N
2255be2d-5432-463d-95e6-e228db6d144e	check_delayed_shipments	2026-09-05 16:00:00.008191	2026-09-05 16:00:00.055677	t	Checked shipments - 0 marked Delayed	\N
f9bd9143-11f3-4525-9959-1df91e4cd69d	check_maintenance_alerts	2026-09-05 16:00:00.05487	2026-09-05 16:00:00.120818	t	Checked 4 record(s); created 0 alert(s)	\N
7268721d-b44e-42f3-aafc-0c66830f1bc2	check_delayed_shipments	2026-09-05 16:10:00.018066	2026-09-05 16:10:00.049983	t	Checked shipments - 0 marked Delayed	\N
7740f1bc-88e4-4e15-b888-64d53da614cb	check_delayed_shipments	2026-09-05 16:20:00.006505	2026-09-05 16:20:00.029044	t	Checked shipments - 0 marked Delayed	\N
8cd5da73-a793-45e7-96f6-2f08f8e06845	check_delayed_shipments	2026-09-05 16:30:00.009809	2026-09-05 16:30:00.037441	t	Checked shipments - 0 marked Delayed	\N
44da782d-6f39-47c3-9e66-9a8977ec9778	check_delayed_shipments	2026-09-05 16:40:00.026986	2026-09-05 16:40:00.04613	t	Checked shipments - 0 marked Delayed	\N
0309a533-7eb7-4965-8696-cd2b735b38c4	check_delayed_shipments	2026-09-05 16:50:00.006596	2026-09-05 16:50:00.03194	t	Checked shipments - 0 marked Delayed	\N
b282e476-ccb7-46ac-80c2-51f55a01f77d	check_delayed_shipments	2026-09-05 17:00:00.021505	2026-09-05 17:00:00.083174	t	Checked shipments - 0 marked Delayed	\N
06bca5cb-ff5c-42db-90a1-d5a30129c6a8	check_maintenance_alerts	2026-09-05 17:00:00.09607	2026-09-05 17:00:00.218073	t	Checked 4 record(s); created 0 alert(s)	\N
44f5df1c-a91f-4dd0-b885-620b273641b0	check_delayed_shipments	2026-09-05 17:10:00.019995	2026-09-05 17:10:00.056496	t	Checked shipments - 0 marked Delayed	\N
876553be-e4a5-4398-a246-5f8e225db8a3	check_delayed_shipments	2026-09-05 17:20:00.015458	2026-09-05 17:20:00.086708	t	Checked shipments - 0 marked Delayed	\N
9726aced-6943-42d3-b9c6-49ec471c9a66	check_delayed_shipments	2026-09-06 05:01:29.837005	2026-09-06 05:01:29.863192	t	Checked shipments - 0 marked Delayed	\N
a9aa2b10-278e-490b-a29c-f3a5890f7278	check_maintenance_alerts	2026-09-06 05:01:29.840598	2026-09-06 05:01:29.896893	t	Checked 4 record(s); created 3 alert(s)	\N
ba9b24b1-9fe7-4f46-9a07-1fbd076b4730	check_delayed_shipments	2026-09-06 05:10:00.015502	2026-09-06 05:10:00.035467	t	Checked shipments - 0 marked Delayed	\N
7e0571b2-27c2-43b1-8d3c-c88aeda98ff4	check_delayed_shipments	2026-09-06 05:20:00.011321	2026-09-06 05:20:00.034232	t	Checked shipments - 0 marked Delayed	\N
6a8203b3-c3c7-4678-8651-b937e2287d40	check_delayed_shipments	2026-09-06 05:30:00.003581	2026-09-06 05:30:00.047923	t	Checked shipments - 0 marked Delayed	\N
56752ef6-d30a-4437-aec3-b82a0a0e1a82	check_delayed_shipments	2026-09-06 05:40:00.006849	2026-09-06 05:40:00.045684	t	Checked shipments - 0 marked Delayed	\N
1503efda-ff66-4f79-b9b3-54d0ec68cd81	check_delayed_shipments	2026-09-06 05:50:00.007233	2026-09-06 05:50:00.037721	t	Checked shipments - 0 marked Delayed	\N
2d4cfb19-749d-4c8e-a8b3-3089067fa01f	check_maintenance_alerts	2026-09-06 06:00:00.042694	2026-09-06 06:00:00.143134	t	Checked 4 record(s); created 0 alert(s)	\N
796ddd2e-82b0-45f6-8729-d752ae8673e8	check_delayed_shipments	2026-09-06 06:00:00.071926	2026-09-06 06:00:00.177024	t	Checked shipments - 0 marked Delayed	\N
dbcc014e-f227-4fa7-ade7-ef416acbfc26	check_delayed_shipments	2026-09-06 06:10:00.0061	2026-09-06 06:10:00.058915	t	Checked shipments - 0 marked Delayed	\N
aed750fb-b086-47b2-877e-22eca9c34e79	check_delayed_shipments	2026-09-06 06:20:00.028787	2026-09-06 06:20:00.073314	t	Checked shipments - 0 marked Delayed	\N
f17ac09c-3437-4496-b882-034584ad1e83	check_delayed_shipments	2026-09-06 06:30:00.041948	2026-09-06 06:30:02.538821	t	Checked shipments - 0 marked Delayed	\N
cb2ee1fa-266d-491d-b3da-964ecb4180a6	check_delayed_shipments	2026-09-06 08:00:29.551643	2026-09-06 08:00:29.568007	t	Checked shipments - 0 marked Delayed	\N
fd97aadd-4b02-480d-a7cb-cd93f02ba8d6	check_delayed_shipments	2026-09-06 08:10:00.025921	2026-09-06 08:10:00.048036	t	Checked shipments - 0 marked Delayed	\N
322a48e0-8d8a-4421-965c-fc7f97dac524	check_delayed_shipments	2026-09-06 08:20:00.009557	2026-09-06 08:20:00.044695	t	Checked shipments - 0 marked Delayed	\N
d6435577-9431-4f17-bdee-4fbf82e28b6d	check_delayed_shipments	2026-09-06 08:30:00.016598	2026-09-06 08:30:00.039216	t	Checked shipments - 0 marked Delayed	\N
3a4b3d09-5e0c-42e3-a0ac-043ba2e9316f	check_delayed_shipments	2026-09-06 08:40:00.012992	2026-09-06 08:40:00.04617	t	Checked shipments - 0 marked Delayed	\N
76ca337d-2b10-42d5-8b19-c9f51c9d81fc	check_delayed_shipments	2026-09-06 08:50:00.006724	2026-09-06 08:50:00.033595	t	Checked shipments - 0 marked Delayed	\N
779d3e28-be28-4ce1-a90d-d07dfd17d397	check_delayed_shipments	2026-09-06 09:00:00.013361	2026-09-06 09:00:00.03973	t	Checked shipments - 0 marked Delayed	\N
3d1cd451-7dc4-4019-8180-04550223d0c9	check_delayed_shipments	2026-09-06 09:10:00.007214	2026-09-06 09:10:00.02892	t	Checked shipments - 0 marked Delayed	\N
01ee4dc9-cf01-4153-a548-a19c32bb2d9c	check_delayed_shipments	2026-09-06 09:20:00.005659	2026-09-06 09:20:00.030591	t	Checked shipments - 0 marked Delayed	\N
83c2c891-f34b-432e-a6fa-1b94d27bd76c	check_delayed_shipments	2026-09-06 12:51:12.719106	2026-09-06 12:51:12.737464	t	Checked shipments - 0 marked Delayed	\N
e969acec-39fa-4a82-a867-dc969e4c7ec3	check_maintenance_alerts	2026-09-06 13:00:00.01363	2026-09-06 13:00:00.111875	t	Checked 4 record(s); created 0 alert(s)	\N
bf292a0f-6b8e-42d1-89fb-4373aba63da4	check_delayed_shipments	2026-09-06 13:10:00.04095	2026-09-06 13:10:00.070752	t	Checked shipments - 0 marked Delayed	\N
c42c14e8-2ed9-4afe-957d-4c94a3b7325f	check_delayed_shipments	2026-09-06 13:20:00.018796	2026-09-06 13:20:00.055195	t	Checked shipments - 1 marked Delayed	\N
3d126781-9acd-4e8a-8ba1-cbf64dcd862f	check_delayed_shipments	2026-09-06 14:50:32.833272	2026-09-06 14:50:32.855056	t	Checked shipments - 0 marked Delayed	\N
2c74aff6-7efe-48a6-958a-3d116458c397	check_maintenance_alerts	2026-09-06 15:04:11.479957	2026-09-06 15:04:11.525757	t	Checked 4 record(s); created 0 alert(s)	\N
7684db46-4ac2-4704-9bb6-d3f8653692ed	check_delayed_shipments	2026-09-06 15:19:22.160194	2026-09-06 15:19:22.184649	t	Checked shipments - 0 marked Delayed	\N
fd1a3156-2d59-4e76-9c6e-34ac6599fcc9	check_delayed_shipments	2026-09-06 15:20:00.013706	2026-09-06 15:20:00.063776	t	Checked shipments - 0 marked Delayed	\N
8b198ec2-2c54-4216-853b-5ce840776541	check_delayed_shipments	2026-09-06 15:30:00.006476	2026-09-06 15:30:00.033427	t	Checked shipments - 0 marked Delayed	\N
c0c93c6f-44ac-4bf5-b77f-bfac61c28113	check_delayed_shipments	2026-09-06 15:40:00.003959	2026-09-06 15:40:00.024873	t	Checked shipments - 0 marked Delayed	\N
a994f65a-b123-4a1c-95f9-faf18c154b30	check_delayed_shipments	2026-09-07 03:15:23.734983	2026-09-07 03:15:23.748289	t	Checked shipments - 0 marked Delayed	\N
8d9f4dff-4fb2-4301-a5fe-a9c124bfe6ce	check_delayed_shipments	2026-09-07 03:20:00.004888	2026-09-07 03:20:00.04288	t	Checked shipments - 0 marked Delayed	\N
137f780d-13a8-40b5-9fcc-58fb10b908fd	check_delayed_shipments	2026-09-07 04:37:57.392441	2026-09-07 04:37:57.403986	t	Checked shipments - 0 marked Delayed	\N
40d76a78-098f-405d-a179-9004eb5d56e6	check_maintenance_alerts	2026-09-06 08:00:29.576581	2026-09-06 08:00:29.651479	t	Checked 4 record(s); created 0 alert(s)	\N
84bcadfa-ddee-4eca-bf58-7b5a973700b6	check_maintenance_alerts	2026-09-06 09:00:00.033293	2026-09-06 09:00:00.082202	t	Checked 4 record(s); created 0 alert(s)	\N
c1fb30ab-40c3-4d73-b151-9d2375161ab5	check_maintenance_alerts	2026-09-06 12:51:12.724469	2026-09-06 12:51:12.767185	t	Checked 4 record(s); created 0 alert(s)	\N
c5d53537-c7bd-4fc6-8f8b-02469f04f369	check_delayed_shipments	2026-09-06 13:00:00.047855	2026-09-06 13:00:00.078025	t	Checked shipments - 0 marked Delayed	\N
8860ba26-a014-4612-aa77-b4cf419e8d02	check_maintenance_alerts	2026-09-06 14:50:32.852106	2026-09-06 14:50:32.917494	t	Checked 4 record(s); created 0 alert(s)	\N
71650aca-0564-4f2b-8d4c-f2d9722fddfe	check_delayed_shipments	2026-09-06 15:04:11.489608	2026-09-06 15:04:11.517048	t	Checked shipments - 0 marked Delayed	\N
464320f6-08be-420e-9d12-12f407316117	check_maintenance_alerts	2026-09-07 03:15:23.73972	2026-09-07 03:15:23.784761	t	Checked 4 record(s); created 0 alert(s)	\N
a9dbd830-6cf2-4a1d-aaa4-598efe1f7760	check_maintenance_alerts	2026-09-07 04:37:57.392965	2026-09-07 04:37:57.415942	t	Checked 4 record(s); created 0 alert(s)	\N
bd930677-93e2-4243-a7e9-5ecc4e0ad170	check_delayed_shipments	2026-09-07 04:40:00.008649	2026-09-07 04:40:00.046066	t	Checked shipments - 0 marked Delayed	\N
cd8fd745-5d2b-41b5-ab5f-c4b5a11afe06	check_delayed_shipments	2026-09-07 04:50:00.025214	2026-09-07 04:50:00.050729	t	Checked shipments - 0 marked Delayed	\N
eb94e608-095c-4232-9aff-f8553a013d6e	check_delayed_shipments	2026-09-07 05:00:00.036792	2026-09-07 05:00:00.064783	t	Checked shipments - 0 marked Delayed	\N
ac934e67-ef51-44ea-b166-c0dc24b5dea3	check_maintenance_alerts	2026-09-07 05:00:00.027773	2026-09-07 05:00:00.085568	t	Checked 4 record(s); created 0 alert(s)	\N
f40973b0-a1c1-47bb-97f4-d1916ad7f1f5	check_delayed_shipments	2026-09-07 05:10:00.004955	2026-09-07 05:10:00.044709	t	Checked shipments - 0 marked Delayed	\N
2250c5de-db1a-4962-9c77-0b8e397e138a	check_delayed_shipments	2026-09-07 05:20:53.421759	2026-09-07 05:20:53.435887	t	Checked shipments - 0 marked Delayed	\N
cc2a228c-033e-404d-bbc1-c1f4547980d3	check_delayed_shipments	2026-09-07 05:30:00.022875	2026-09-07 05:30:00.060815	t	Checked shipments - 0 marked Delayed	\N
038d5dda-ace2-4af5-9464-57d76542ef7a	check_delayed_shipments	2026-09-07 05:40:00.058419	2026-09-07 05:40:00.079867	t	Checked shipments - 0 marked Delayed	\N
42594352-6392-49d4-96b0-4aa1cdf5c00d	check_delayed_shipments	2026-09-07 05:50:00.037051	2026-09-07 05:50:00.062308	t	Checked shipments - 0 marked Delayed	\N
8d5362b2-3802-4bfd-b845-31f28c38f323	check_maintenance_alerts	2026-09-07 06:00:00.073906	2026-09-07 06:00:00.107648	t	Checked 4 record(s); created 0 alert(s)	\N
020a329b-f5e2-49d8-9f99-389a4eb2da66	check_delayed_shipments	2026-09-07 06:00:00.094654	2026-09-07 06:00:00.151767	t	Checked shipments - 0 marked Delayed	\N
2d81ac10-bc95-49cc-a862-bca95bf3d94c	check_delayed_shipments	2026-09-07 06:10:00.013407	2026-09-07 06:10:00.080421	t	Checked shipments - 0 marked Delayed	\N
c72be3a7-3c34-46b5-8636-9182931cc0ae	check_delayed_shipments	2026-09-07 06:20:00.014007	2026-09-07 06:20:00.027848	t	Checked shipments - 0 marked Delayed	\N
f4a6cc7b-ae8f-47ec-8c6d-c38e9af7f977	check_delayed_shipments	2026-09-07 06:30:00.065718	2026-09-07 06:30:00.105857	t	Checked shipments - 0 marked Delayed	\N
f12b4195-6428-4273-81c6-5a8c70e2a395	check_delayed_shipments	2026-09-07 06:40:00.045757	2026-09-07 06:40:00.174293	t	Checked shipments - 0 marked Delayed	\N
b8763f1e-e1de-49a4-a694-592d3cb437a0	check_delayed_shipments	2026-09-07 06:50:00.011418	2026-09-07 06:50:00.084681	t	Checked shipments - 0 marked Delayed	\N
6a29e21b-705f-4394-8261-03458a55f261	check_delayed_shipments	2026-09-07 07:00:00.018896	2026-09-07 07:00:00.096822	t	Checked shipments - 0 marked Delayed	\N
6e4889ad-d8c3-4e71-be5d-628f61ecf36d	check_maintenance_alerts	2026-09-07 07:00:00.116986	2026-09-07 07:00:00.287576	t	Checked 4 record(s); created 0 alert(s)	\N
2a13723e-5220-406b-abd5-4cb8fc67f674	check_delayed_shipments	2026-09-07 07:10:00.024597	2026-09-07 07:10:00.060814	t	Checked shipments - 0 marked Delayed	\N
3d15fc98-4a45-4a28-941e-0ca6754f5d12	check_delayed_shipments	2026-09-07 07:20:00.004804	2026-09-07 07:20:00.038719	t	Checked shipments - 0 marked Delayed	\N
71d048eb-07af-4e5a-a625-e2d8c0b7cc9f	check_delayed_shipments	2026-09-07 08:35:04.139599	2026-09-07 08:35:04.179284	t	Checked shipments - 0 marked Delayed	\N
1419daee-c291-4710-a3fe-cb5b71727f2d	check_maintenance_alerts	2026-09-07 08:35:04.163214	2026-09-07 08:35:04.320547	t	Checked 4 record(s); created 0 alert(s)	\N
876bdfe5-b5bd-4d1d-b183-c0a005835f2f	check_delayed_shipments	2026-09-07 08:40:00.004725	2026-09-07 08:40:00.051955	t	Checked shipments - 0 marked Delayed	\N
7e2d32ab-f844-494b-b9c4-b93b41fe1df0	check_delayed_shipments	2026-09-07 08:50:00.006851	2026-09-07 08:50:00.035561	t	Checked shipments - 0 marked Delayed	\N
e66c3ad9-6087-4252-94f0-62cef3121639	check_delayed_shipments	2026-09-07 09:00:00.006324	2026-09-07 09:00:00.0296	t	Checked shipments - 0 marked Delayed	\N
ea7c681d-7752-4f53-b509-52429440ef53	check_maintenance_alerts	2026-09-07 09:00:00.012567	2026-09-07 09:00:00.046691	t	Checked 4 record(s); created 0 alert(s)	\N
17c27114-546f-42f7-b72f-e9aa9f8786b1	check_delayed_shipments	2026-09-07 09:10:00.005705	2026-09-07 09:10:00.033043	t	Checked shipments - 0 marked Delayed	\N
dcbe740f-407a-462c-83bc-b46f5577f81c	check_delayed_shipments	2026-09-07 09:20:00.00639	2026-09-07 09:20:00.07643	t	Checked shipments - 0 marked Delayed	\N
0b87c6fd-0ba7-4587-b1bd-1c1c25d7c665	check_delayed_shipments	2026-09-07 09:30:00.005624	2026-09-07 09:30:00.033311	t	Checked shipments - 0 marked Delayed	\N
90d9eda1-ba7f-422e-b8c7-20304f09695e	check_delayed_shipments	2026-09-07 09:40:00.016499	2026-09-07 09:40:00.036452	t	Checked shipments - 0 marked Delayed	\N
b3f86170-8877-45c2-97ee-1608dad398be	check_delayed_shipments	2026-09-07 09:50:00.006278	2026-09-07 09:50:00.03924	t	Checked shipments - 0 marked Delayed	\N
680adbba-a218-4104-b91b-2e4634e62f36	check_maintenance_alerts	2026-09-07 10:00:00.010094	2026-09-07 10:00:00.060427	t	Checked 4 record(s); created 0 alert(s)	\N
43127c37-2079-47af-a5bb-9e6b77b45951	check_delayed_shipments	2026-09-07 10:00:00.035658	2026-09-07 10:00:00.082617	t	Checked shipments - 0 marked Delayed	\N
cce24b2f-fb55-4f78-814e-fc733af23a9b	check_delayed_shipments	2026-09-07 10:10:00.012752	2026-09-07 10:10:00.040571	t	Checked shipments - 0 marked Delayed	\N
f31c9b27-10b7-492d-8870-55e9ff4a042a	check_delayed_shipments	2026-09-07 10:29:25.422689	2026-09-07 10:29:25.434571	t	Checked shipments - 0 marked Delayed	\N
99d1fddf-dcee-4191-b7e5-2041b30abe19	check_delayed_shipments	2026-09-07 10:30:00.002914	2026-09-07 10:30:00.023607	t	Checked shipments - 0 marked Delayed	\N
c4437c55-7b92-4612-8987-a3217c32a57f	check_delayed_shipments	2026-09-07 10:40:00.029713	2026-09-07 10:40:00.069227	t	Checked shipments - 0 marked Delayed	\N
cf935241-9f9a-4eab-a543-51a58e010b87	check_delayed_shipments	2026-09-07 10:50:00.011212	2026-09-07 10:50:00.051162	t	Checked shipments - 0 marked Delayed	\N
fe6fe218-e835-4012-a0ce-4e56104af2a6	check_maintenance_alerts	2026-09-07 11:00:00.011738	2026-09-07 11:00:00.077497	t	Checked 4 record(s); created 0 alert(s)	\N
dafa8c8e-d36f-4b50-b952-7d432fc4de07	check_delayed_shipments	2026-09-07 11:00:00.040365	2026-09-07 11:00:00.11203	t	Checked shipments - 0 marked Delayed	\N
787950bf-87a4-40e8-b296-c3cdd24fbcf0	check_delayed_shipments	2026-09-07 11:10:00.014232	2026-09-07 11:10:00.061688	t	Checked shipments - 0 marked Delayed	\N
aea17fc9-b929-49ae-aa69-b487465ed231	check_delayed_shipments	2026-09-07 11:20:00.01609	2026-09-07 11:20:00.03143	t	Checked shipments - 0 marked Delayed	\N
2410cf0a-d7a8-4d4d-8a76-3e1dde5e8250	check_delayed_shipments	2026-09-07 14:22:18.324117	2026-09-07 14:22:18.49388	t	Checked shipments - 0 marked Delayed	\N
027fbb72-f925-446d-b678-fd6e0dc9ac76	check_maintenance_alerts	2026-09-07 14:22:18.334643	2026-09-07 14:22:19.065449	t	Checked 4 record(s); created 0 alert(s)	\N
fd2c9c58-5743-4112-9aa1-7290aa3ce8d9	check_delayed_shipments	2026-09-07 14:30:00.013955	2026-09-07 14:30:00.03466	t	Checked shipments - 0 marked Delayed	\N
53ffdffa-e0ed-4dc0-ae06-819538b051f3	check_delayed_shipments	2026-09-07 14:40:00.007107	2026-09-07 14:40:00.040833	t	Checked shipments - 0 marked Delayed	\N
1dea4c44-ac30-4b64-962e-4dc1fb5ae7ef	check_delayed_shipments	2026-09-07 14:50:00.003638	2026-09-07 14:50:00.018873	t	Checked shipments - 0 marked Delayed	\N
b8fe2d75-4ec0-49f9-a4d9-e884d0712838	check_delayed_shipments	2026-09-07 15:00:00.008535	2026-09-07 15:00:00.05168	t	Checked shipments - 0 marked Delayed	\N
8989b593-6835-4a3d-8821-20edc24c09f6	check_maintenance_alerts	2026-09-07 15:00:00.045891	2026-09-07 15:00:00.132844	t	Checked 4 record(s); created 0 alert(s)	\N
6405c153-9eae-42d6-ab75-9b9fdf039314	check_delayed_shipments	2026-09-07 15:10:00.024194	2026-09-07 15:10:00.054271	t	Checked shipments - 0 marked Delayed	\N
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leave_requests (leave_id, driver_id, leave_date, reason, status, reviewed_by, created_at) FROM stdin;
f14b96ee-d094-4e20-ab5b-12b3a73d6f22	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-08-12	health issue suffering from fever	Rejected	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-10 17:50:47.913176
285c3090-4812-4584-9715-81cea6e71595	5f141cfc-3848-4337-9e00-59eec4d587a3	2026-08-26	Health issue	Approved	670871bb-6e48-431e-ae05-1b56663c0a7b	2026-08-26 15:03:09.351546
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (notification_id, user_id, title, message, is_read, created_at, type) FROM stdin;
c92a28a6-8f22-42aa-86c0-7f1001b26b0c	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:53:02.326302	route
59def377-9e76-4148-a920-ed50b479ddf7	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:53:02.330811	route
b344dcf4-d403-46f0-8e17-2cbc74a3becc	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 15:14:46.249534	route
77f39e47-e428-4dd5-9b4b-609ba1e7e86d	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 15:14:46.249747	route
45b60505-9859-43b9-a2ff-619e849da9ab	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has started.	f	2026-09-03 13:05:25.025658	shipment
53f18544-1e77-40ea-a766-b532d004426e	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has started.	f	2026-09-03 13:05:25.025916	shipment
d6c2163c-cfb7-4647-92f8-90a7d8ea72e4	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:53:02.330686	route
cfddefec-a238-4221-bf2d-6ca6f50092b1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 15:14:46.2497	route
b6c1af67-1aa0-482e-bb3a-4d2dc6d1083b	670871bb-6e48-431e-ae05-1b56663c0a7b	Upcoming maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 requires servicing by 2026-08-26T20:30:00.	t	2026-08-26 16:41:43.420049	info
2c4d8453-503e-44db-a499-2e6070cac433	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Driver assignment updated	Driver Hemanth was assigned to vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32.	f	2026-08-28 05:27:33.021837	assignment
4e0aa752-d3c2-42df-a857-0aadd2ae9467	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has started.	t	2026-09-03 13:05:25.025857	shipment
46f4a34e-b48c-46a5-a4c7-636efa5110e7	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has delivered.	f	2026-09-05 13:05:41.415966	shipment
2d334cfe-ad92-47f0-a6f1-ee1a74786bf2	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has delivered.	f	2026-09-05 13:05:41.416177	shipment
2a1ab2d2-1d39-4fd2-9a48-e9aa42be4481	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has delivered.	f	2026-09-05 13:10:42.619622	shipment
d444a555-492c-4d3e-82e9-8af20b838307	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has delivered.	f	2026-09-05 13:10:42.619703	shipment
f4065fed-f7f8-410b-b53b-805e54f2bd58	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Maintenance scheduled	Break Failure maintenance is scheduled for vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32.	f	2026-09-05 13:13:08.043743	maintenance
f99cca6c-6900-458c-a93d-ae45c285d569	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip 2b178a09-ce2c-424a-89fb-5f87d3436539 has started.	f	2026-09-05 13:14:06.210586	shipment
816cf732-75cd-4600-9a40-a19d2d1de254	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip 2b178a09-ce2c-424a-89fb-5f87d3436539 has started.	f	2026-09-05 13:14:06.210695	shipment
1a05c454-6b4f-44d5-9ac6-0ae8913c40de	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:24:45.694989	route
0a0d4cef-fdd4-4e01-9b9d-9e458ba6ad7e	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:24:45.695126	route
f448244c-1773-4966-b59c-19e354715ad6	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:28:47.241469	route
5c2f8fd7-32c0-43d9-854b-b91b6572741d	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:28:47.24171	route
66abb428-5579-4cb7-8457-5f63c6e7d18c	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:29:05.069616	route
3253c687-8beb-44f0-9dc5-1da7fb6b0fac	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:29:05.069727	route
85bc7c35-4d42-43c1-9ec4-d7d978e72f2e	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:29:11.451182	route
716b08d3-730e-4979-b860-6f0bc2d3e7ed	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Overdue maintenance: f362ccbf-24bf-4e5c-b174-dabf852cd8ce	Vehicle e8730316-9126-485f-9dac-ceca230b2ab3 requires Oil change by 2026-08-21T20:14:00.	f	2026-08-27 13:00:00.280696	info
e497fb78-6224-46e0-af90-6e8b60ffbf1e	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:53:02.330446	route
c0b7bea6-fcd9-4664-a523-e02eb958247d	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 15:14:46.249647	route
0b3dfe05-24cf-4ade-aa0f-fc16566ac198	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has started.	t	2026-09-03 13:05:25.025792	shipment
26ce7df6-fa78-4c99-94d6-87a141661c8b	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has delivered.	t	2026-09-05 13:05:41.416101	shipment
8f1a3c28-f0e0-4c24-a1c7-2662e4764413	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has delivered.	t	2026-09-05 13:10:42.619673	shipment
7580e84e-a720-42d1-b278-6123cd826d63	670871bb-6e48-431e-ae05-1b56663c0a7b	Maintenance scheduled	Break Failure maintenance is scheduled for vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32.	t	2026-09-05 13:13:08.043813	maintenance
9e65025e-b9c6-4c79-8108-c5ee3d189b22	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip 2b178a09-ce2c-424a-89fb-5f87d3436539 has started.	t	2026-09-05 13:14:06.210657	shipment
ea410703-4286-4ee8-9c29-d47a3212897d	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:24:45.695092	route
e1604505-8788-41a5-819e-648d344ab2c8	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:53:08.555838	route
06884898-4c62-4541-b3df-eda2c5b92678	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	5-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance in 5 days (2026-08-31T15:01:07.315234).	f	2026-08-28 06:04:12.072026	maintenance
5abeffcf-74e1-416b-a6d1-5b19ba453b51	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:53:08.556094	route
5c281bd5-291d-41d6-b3b7-6f29497e97d0	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 15:13:24.339966	route
4ce55d2d-81cb-4097-a8b4-d9005e04c1a7	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	5-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance in 5 days (2026-09-02T05:29:47.231481).	f	2026-08-28 12:04:47.608993	maintenance
20f8ae84-c7fb-40c9-92ed-25451b2d369a	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 15:13:24.340201	route
1d729586-3da6-4225-a02c-e791b4cd97d7	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has started.	f	2026-08-28 12:29:29.66068	shipment
97fb8007-7249-49cd-af84-1b505e9c14ab	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has started.	f	2026-08-28 12:29:29.660724	shipment
60366dcb-6828-4cb4-8c1d-10131c856a39	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	5-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance in 5 days (2026-08-31T15:01:07.315234).	t	2026-08-28 06:04:12.072019	maintenance
f9eccdcc-f120-462d-b42a-b62978565d8c	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has delivered.	f	2026-08-28 12:29:32.910673	shipment
3cdf9370-a9ce-40b1-afcc-551e8c218d0c	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has delivered.	f	2026-08-28 12:29:32.910714	shipment
952897b9-3386-4a3f-9e4a-3ff0b7d11082	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 0d790a49-83f4-4331-a050-db7cfdf27299 was recalculated using Fastest Route.	f	2026-08-28 12:57:15.660136	route
a6cf02ca-3c84-44ec-9bc3-8c0e682c949d	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Trip started	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has started.	t	2026-08-28 12:29:29.660743	shipment
a7a419e1-202b-4c6e-a561-6a56e78bb88c	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 0d790a49-83f4-4331-a050-db7cfdf27299 was recalculated using Fastest Route.	f	2026-08-28 12:57:15.660337	route
c1df2002-ad30-483a-9df7-fd2c86132e55	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:53:08.556038	route
048e8df3-0c89-4f82-aaff-91063c8fdbc2	676cf171-d65a-47bd-bfda-fdcef73439cc	Welcome	Your account has been created successfully.	f	2026-08-29 13:10:59.2385	info
ac057ba6-edaa-40e5-8066-b290323d84f2	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 15:13:24.340149	route
4efd89d4-d62b-4f6b-9482-904cbc782c0d	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Shipment Delivered	Shipment SHIP002 is now delivered.	f	2026-08-29 16:12:21.059407	shipment
2127c048-de8d-4642-a057-dba1a502a1c7	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Shipment Delivered	Shipment SHIP002 is now delivered.	f	2026-08-29 16:12:21.059448	shipment
6eef0686-a243-41c1-a03f-9dc49a740324	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:53:08.555972	route
9016069f-8c3d-4d98-9e07-fc2d25596648	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has started.	f	2026-08-29 16:16:03.163982	shipment
6efc4f2a-020f-4e13-a99b-5a2638a60575	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has started.	f	2026-08-29 16:16:03.164023	shipment
ea10344d-d787-4368-b394-41fab9680fa8	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 15:13:24.340088	route
ac76c6c0-1735-4802-981a-0235d0026683	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Shipment delayed	Shipment SHIP003 has been delayed after 24 hours in transit.	f	2026-08-29 16:20:00.046907	shipment
7300c5e2-e5e5-4056-b75d-44d8eec3dafc	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Shipment delayed	Shipment SHIP003 has been delayed after 24 hours in transit.	f	2026-08-29 16:20:00.046962	shipment
2ecd7c1d-efe4-4609-a9f3-db5983043a6a	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	1-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance tomorrow (2026-08-31T15:01:07.315234).	f	2026-08-30 15:03:07.281682	maintenance
279ba5dd-d41d-4909-93d3-d034b3c6f7fb	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has delivered.	f	2026-08-31 12:17:53.556982	shipment
6f9c264f-becc-4566-82c7-98a9c0470064	670871bb-6e48-431e-ae05-1b56663c0a7b	5-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance in 5 days (2026-08-31T15:01:07.315234).	t	2026-08-28 06:04:12.072029	maintenance
f7ed87b9-0723-4fe2-8257-13d63f963dbe	670871bb-6e48-431e-ae05-1b56663c0a7b	5-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance in 5 days (2026-09-02T05:29:47.231481).	t	2026-08-28 12:04:47.608996	maintenance
a9240bf6-921b-45cd-9df7-b8a7f048a45d	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has started.	t	2026-08-28 12:29:29.660706	shipment
5cdf432a-590b-4e14-bbe9-8a8a6c214eff	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has delivered.	t	2026-08-28 12:29:32.910696	shipment
8f507772-ed6e-4308-91ee-0ab8d69a2ca9	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 0d790a49-83f4-4331-a050-db7cfdf27299 was recalculated using Fastest Route.	t	2026-08-28 12:57:15.660289	route
99d7daa4-2910-4980-9ddf-c01254dcffee	670871bb-6e48-431e-ae05-1b56663c0a7b	Shipment Delivered	Shipment SHIP002 is now delivered.	t	2026-08-29 16:12:21.059431	shipment
610d9e3c-21ab-406d-bf7d-193072078e50	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has started.	t	2026-08-29 16:16:03.164006	shipment
fb19c837-919f-4da0-a09c-1f80269f71c4	670871bb-6e48-431e-ae05-1b56663c0a7b	Shipment delayed	Shipment SHIP003 has been delayed after 24 hours in transit.	t	2026-08-29 16:20:00.046944	shipment
e9876710-7bc4-4e97-b859-0032f53c8600	670871bb-6e48-431e-ae05-1b56663c0a7b	1-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance tomorrow (2026-08-31T15:01:07.315234).	t	2026-08-30 15:03:07.281687	maintenance
68be771f-0cb5-477f-aee0-19eb90da5783	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has delivered.	f	2026-08-31 12:17:53.557032	shipment
a2ada01c-1bde-492c-aaea-cf7d5e64d6d9	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	f	2026-09-02 14:53:29.046634	route
74c69938-3854-4c79-97f9-b0ebec1b4cc4	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has started.	f	2026-08-31 12:17:57.5337	shipment
787db2e5-fc60-474f-9e13-f2ac05a2a846	676cf171-d65a-47bd-bfda-fdcef73439cc	Trip started	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has started.	f	2026-08-31 12:17:57.533737	shipment
b33031fd-207b-4da3-8c25-4f86b20ff394	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has started.	f	2026-08-31 12:17:57.533752	shipment
4a0510e3-16cc-4dec-9684-91344d4083eb	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Shipment delayed	Shipment SHIP005 has been delayed after 24 hours in transit.	f	2026-08-31 12:18:51.355821	shipment
16670e89-c1d8-44e3-92f2-91437d06a352	676cf171-d65a-47bd-bfda-fdcef73439cc	Shipment delayed	Shipment SHIP005 has been delayed after 24 hours in transit.	f	2026-08-31 12:18:51.355898	shipment
2ebda2ec-f3bb-412a-9c76-97e11092be47	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Shipment delayed	Shipment SHIP005 has been delayed after 24 hours in transit.	f	2026-08-31 12:18:51.355913	shipment
b881895e-d745-41db-ae54-690ed888c2c6	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-08-31)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	f	2026-08-31 16:00:00.179692	maintenance
0835964c-6e4b-45a1-9d01-944df753ea81	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-09-01)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	f	2026-09-01 05:52:30.462618	maintenance
198ee973-aca7-4580-97ad-58dcc7818ac6	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	f	2026-09-02 14:53:29.047131	route
870a2f85-b869-4e82-958b-ecb34b4abd2f	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	1-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance tomorrow (2026-09-02T05:29:47.231481).	f	2026-09-01 05:52:30.462636	maintenance
c51d7363-0313-4a0f-b49f-ec91cdecc968	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Trip delivered	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has delivered.	t	2026-08-28 12:29:32.91073	shipment
43600f66-e517-4129-aaa8-497b272eed55	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Shipment Delivered	Shipment SHIP002 is now delivered.	t	2026-08-29 16:12:21.059465	shipment
c262ff77-2c55-49ab-9189-5550cfe26a49	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has delivered.	f	2026-09-01 14:46:06.277859	shipment
d7c207f1-0d0c-4b61-8858-be207d86343f	676cf171-d65a-47bd-bfda-fdcef73439cc	Trip delivered	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has delivered.	f	2026-09-01 14:46:06.277914	shipment
dd17be25-6023-47cb-9e4c-b73b9b4af697	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has delivered.	f	2026-09-01 14:46:06.277935	shipment
09e26acc-be89-47a5-92ca-a7b0b969152a	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Maintenance scheduled	Maintenance for vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 has been resolved.	f	2026-09-01 14:49:32.607668	maintenance
efc35d81-59bf-45a8-bf1c-467f7aaef5d8	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Trip started	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has started.	t	2026-08-29 16:16:03.164039	shipment
e97f7d92-d75e-40df-8f25-d6433498aaba	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has started.	f	2026-09-01 14:53:56.5121	shipment
bc7a6069-054b-493d-bd96-7f126b3df693	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Shipment delayed	Shipment SHIP003 has been delayed after 24 hours in transit.	t	2026-08-29 16:20:00.046976	shipment
b2538d0e-0f47-40ea-92c7-0f2f92fc0781	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	1-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance tomorrow (2026-08-31T15:01:07.315234).	t	2026-08-30 15:03:07.281646	maintenance
7cd719c5-14d0-495d-99ed-658c6cbe1496	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has started.	f	2026-09-01 14:53:56.512179	shipment
25caad3a-8562-489b-bab8-b74238942be7	d3faa1bd-5b40-4e14-bd47-227d9f34f689	5-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance in 5 days (2026-09-02T05:29:47.231481).	t	2026-08-28 12:04:47.608999	maintenance
c3a0a9ff-c244-4e19-8981-e0da71ca63c1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has started.	t	2026-08-28 12:29:29.660582	shipment
fe7b5f74-cbf1-4c81-987c-1607a394aeb1	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip 9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851 has delivered.	t	2026-08-28 12:29:32.910606	shipment
207d8dd9-0ee6-4560-8939-1ddd59072529	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 0d790a49-83f4-4331-a050-db7cfdf27299 was recalculated using Fastest Route.	t	2026-08-28 12:57:15.660316	route
da80e2f5-46e9-45ae-82f5-5f08f7183ce1	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has delivered.	t	2026-08-31 12:17:53.557011	shipment
184c4de0-9f4a-4996-8aca-91c68a58714b	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has started.	t	2026-08-31 12:17:57.533721	shipment
fc13cd06-1e85-4f5b-9e18-cf56957e29ca	670871bb-6e48-431e-ae05-1b56663c0a7b	Shipment delayed	Shipment SHIP005 has been delayed after 24 hours in transit.	t	2026-08-31 12:18:51.355879	shipment
b90eb016-a4fc-4042-a290-5d0c7a868b0f	670871bb-6e48-431e-ae05-1b56663c0a7b	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-08-31)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-08-31 16:00:00.179699	maintenance
b3cae28b-207b-4047-a5de-d57393f72d65	670871bb-6e48-431e-ae05-1b56663c0a7b	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-09-01)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-09-01 05:52:30.462626	maintenance
0a38e5fb-6e6b-4aa5-9abb-24c59fe1970c	670871bb-6e48-431e-ae05-1b56663c0a7b	1-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance tomorrow (2026-09-02T05:29:47.231481).	t	2026-09-01 05:52:30.46264	maintenance
094a71f7-451f-4476-9ecf-cbb52a687946	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has delivered.	t	2026-09-01 14:46:06.277888	shipment
df0a09b3-52e8-4aba-8b53-27f110aef882	670871bb-6e48-431e-ae05-1b56663c0a7b	Maintenance scheduled	Maintenance for vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 has been resolved.	t	2026-09-01 14:49:32.607701	maintenance
8dc2f2bc-5c22-43a3-8555-e3912c8fe041	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Trip delivered	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has delivered.	t	2026-08-31 12:17:53.557047	shipment
6bf56ee8-ee6a-49f0-a348-4d5d6a9e1ddb	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	t	2026-09-02 14:53:29.047039	route
8358da5f-1aaf-42f2-a012-c979cbcdfb52	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	t	2026-09-02 14:53:29.046926	route
711270a6-37b0-4d10-96d3-667c849a2ff2	d3faa1bd-5b40-4e14-bd47-227d9f34f689	5-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance in 5 days (2026-08-31T15:01:07.315234).	t	2026-08-28 13:00:00.131569	maintenance
a0156c9c-2065-4eb0-9d55-4b4d6b5dc83c	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Shipment Delivered	Shipment SHIP002 is now delivered.	t	2026-08-29 16:12:21.059333	shipment
c9e33401-01f7-4d12-a025-6055129788fa	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has started.	t	2026-08-29 16:16:03.163894	shipment
1e58e7eb-0a97-44c7-9d0a-216d7d52e48e	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Shipment delayed	Shipment SHIP003 has been delayed after 24 hours in transit.	t	2026-08-29 16:20:00.046808	shipment
d29563d3-fe1a-49e1-9a83-10e430b45a32	d3faa1bd-5b40-4e14-bd47-227d9f34f689	1-day maintenance reminder: 055480bd-4156-4829-8b88-5aa4b2a8170d	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 is due for servicing maintenance tomorrow (2026-08-31T15:01:07.315234).	t	2026-08-30 15:03:07.281691	maintenance
a3e131d4-7b2a-4c11-9b54-66dc73dbe1db	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip 0d790a49-83f4-4331-a050-db7cfdf27299 has delivered.	t	2026-08-31 12:17:53.556756	shipment
42e35309-ce1c-49e5-9fa1-18214f71ba21	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has started.	t	2026-08-31 12:17:57.533611	shipment
0802c2b5-6281-4f3d-93e7-a65e62dba892	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Shipment delayed	Shipment SHIP005 has been delayed after 24 hours in transit.	t	2026-08-31 12:18:51.352988	shipment
8735ebfc-ed7c-4a0d-b5ba-6df558c690f6	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-08-31)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-08-31 16:00:00.179704	maintenance
a954740e-de36-4e05-8946-5825be5e6deb	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-09-01)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-09-01 05:52:30.462631	maintenance
fd13f9f9-112f-45a1-8cd2-d7386a90e39a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	1-day maintenance reminder: 68049d4b-f0af-47e4-b43b-63b15e6a5951	Vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd is due for Changing tyres maintenance tomorrow (2026-09-02T05:29:47.231481).	t	2026-09-01 05:52:30.462644	maintenance
c5f81352-3f3e-4cc6-bea1-cba4733172ec	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip e0178854-739f-48c7-8403-d4e2fcf5d8ab has delivered.	t	2026-09-01 14:46:06.277775	shipment
025fda05-cd54-4f55-a01e-8fa35e1e5f6f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Maintenance scheduled	Maintenance for vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 has been resolved.	t	2026-09-01 14:49:32.607728	maintenance
f7df2f5a-f82e-45a9-92c4-d1a401d1ca13	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has started.	t	2026-09-01 14:53:56.512165	shipment
40d8cbf4-0bcf-42d9-9ea6-26859dbcaa41	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip started	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has started.	f	2026-09-02 12:14:34.72487	shipment
39d7e855-ccbd-4dd4-a26b-6eb8fcf331ae	676cf171-d65a-47bd-bfda-fdcef73439cc	Trip started	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has started.	f	2026-09-02 12:14:34.724963	shipment
4a079d81-ed00-447e-8239-eb9a42ca85ce	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip started	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has started.	f	2026-09-02 12:14:34.724997	shipment
a6f73c41-6dd9-4978-91c0-7229d8c0f549	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Trip delivered	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has delivered.	f	2026-09-02 12:14:37.254088	shipment
e20bb659-fd47-417c-85be-40c05e0d757f	676cf171-d65a-47bd-bfda-fdcef73439cc	Trip delivered	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has delivered.	f	2026-09-02 12:14:37.254174	shipment
7a0a0a49-9b11-43e6-9778-a11ab58a14cb	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Trip delivered	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has delivered.	f	2026-09-02 12:14:37.254203	shipment
3127ec85-ec24-43d6-adc8-70fa9170f2be	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has started.	t	2026-09-01 14:53:56.512148	shipment
28d62ae4-9bfd-45a7-a72e-7a4e5b3e071c	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip started	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has started.	t	2026-09-02 12:14:34.724927	shipment
2641d837-7b31-45fd-a167-df379ff73b88	670871bb-6e48-431e-ae05-1b56663c0a7b	Trip delivered	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has delivered.	t	2026-09-02 12:14:37.254138	shipment
ebabf03f-e141-451a-b8dd-2027109d104b	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:58:56.144596	route
f63bef46-cb4b-4ef5-ab84-bebcc45a2e30	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	f	2026-09-02 14:58:56.144866	route
6dcb6112-e3ab-4476-8e4c-2da25a981a9e	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	f	2026-09-02 15:13:45.957011	route
d1d2ce0a-40ab-4922-8bc0-29d2e1ffd067	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	f	2026-09-02 15:13:45.957672	route
a9c666fe-8856-4de0-9ff2-22e1ed899604	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-08-31)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-08-31 16:00:00.179648	maintenance
533e2ae2-72d4-4fc1-9388-c8561faff35c	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Due maintenance: 055480bd-4156-4829-8b88-5aa4b2a8170d (2026-09-01)	Vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 maintenance for servicing is overdue (due 2026-08-31T15:01:07.315234).	t	2026-09-01 05:52:30.462579	maintenance
6770f940-2953-4be6-bd3f-e9bdb52aa467	c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	Maintenance scheduled	Maintenance for vehicle b84072f3-0a48-4973-aa6e-b51be31b1b79 has been resolved.	t	2026-09-01 14:49:32.607584	maintenance
95448ae4-37f6-4536-88fa-acfb73ee4283	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has started.	t	2026-09-02 12:14:34.724691	shipment
6b843947-9d16-4fad-936b-332df2f7f682	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip ab2a769c-6f11-4f08-b078-ca01b3f08dff has delivered.	t	2026-09-02 12:14:37.253978	shipment
ac2dcf1c-404c-4a1b-8bad-d7599ef29c8a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:58:56.144806	route
b2f5d44c-feb4-4bff-b62d-bf46758c01b2	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	t	2026-09-02 15:13:45.957624	route
41cb74b2-8260-4f9e-ba65-ac8aed58af5a	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Shipment delayed	Shipment SHIP007 has been delayed after 24 hours in transit.	f	2026-09-05 13:10:00.308357	shipment
c26dffed-cff2-4384-beca-f93031fddafb	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Shipment delayed	Shipment SHIP007 has been delayed after 24 hours in transit.	f	2026-09-05 13:10:00.30862	shipment
8f2c9aa9-de8a-426b-b861-682903dab576	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Maintenance scheduled	Maintenance for vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd has been resolved.	f	2026-09-05 13:12:19.659885	maintenance
7ce925be-0df1-4592-a88b-0a99924e60a8	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Fastest Route.	t	2026-09-02 14:58:56.144737	route
3e2a17e3-888e-4382-8e0c-bcf27c81375a	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 13ff480c-fb98-4b61-be95-901e52a68023 was recalculated using Shortest Route.	t	2026-09-02 15:13:45.957567	route
4f1ce5d1-8c9d-4722-b81c-149138fd504e	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-05 13:29:11.451284	route
8df1ddb1-74d1-497c-ac7d-db92ba0d485b	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	5-day maintenance reminder: 233928dc-762b-4ee4-9d1d-e5118cce3545	Vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32 is due for Break Failure maintenance in 5 days (2026-09-10T18:42:00).	f	2026-09-06 05:01:29.910989	maintenance
7a4309fe-00bd-4ecb-960a-22b5ad39e193	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Shipment delayed	Shipment SHIP008 has been delayed after 24 hours in transit.	f	2026-09-06 13:20:00.052247	shipment
052b96b5-9a67-4e53-b9fb-da868dd66970	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Shipment delayed	Shipment SHIP008 has been delayed after 24 hours in transit.	f	2026-09-06 13:20:00.054017	shipment
7048902f-af70-49b2-a974-412de9684458	bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-07 05:40:50.068649	route
bda6188f-83da-41a4-9fd7-80d27f62ad06	b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	f	2026-09-07 05:40:50.068881	route
b19c9fd8-595e-4400-bd6d-5bee5efcc019	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip 13ff480c-fb98-4b61-be95-901e52a68023 has delivered.	t	2026-09-05 13:05:41.416146	shipment
f9d17916-039c-4754-b4d7-ff2a7409852c	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip delivered	Trip f98780fe-763c-4cb2-a3fc-e68e0055c30e has delivered.	t	2026-09-05 13:10:42.619689	shipment
55c8ff61-d73e-4e0a-86f8-76846d059b6a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Maintenance scheduled	Break Failure maintenance is scheduled for vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32.	t	2026-09-05 13:13:08.043828	maintenance
8de10e97-6516-48d7-9ab7-39550e1cad53	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Trip started	Trip 2b178a09-ce2c-424a-89fb-5f87d3436539 has started.	t	2026-09-05 13:14:06.210679	shipment
98f0d394-9eb1-46fe-8411-a4ca93ce52f4	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:24:45.695114	route
be822f0b-b56e-4876-963c-633307021c8a	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:28:47.241684	route
e7b2ed58-e8c6-4dde-8ea9-f234d66cd267	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:29:05.069714	route
ad37665b-684b-4d97-9aef-13ffb0fa501f	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:29:11.45127	route
f85d26a8-ccb9-4db6-87a2-9e8006eaff73	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Shipment delayed	Shipment SHIP007 has been delayed after 24 hours in transit.	t	2026-09-05 13:10:00.308605	shipment
1a536b3a-28e5-43ee-9875-76166a8934a4	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Maintenance scheduled	Maintenance for vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd has been resolved.	t	2026-09-05 13:12:19.659962	maintenance
17a6b62a-e3f2-46bb-8d6f-d33c87a1b203	d3faa1bd-5b40-4e14-bd47-227d9f34f689	5-day maintenance reminder: 233928dc-762b-4ee4-9d1d-e5118cce3545	Vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32 is due for Break Failure maintenance in 5 days (2026-09-10T18:42:00).	t	2026-09-06 05:01:29.911023	maintenance
47423b2b-9d50-4f56-aaa8-28a20bd5fff3	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Shipment delayed	Shipment SHIP008 has been delayed after 24 hours in transit.	t	2026-09-06 13:20:00.053999	shipment
ffbfba15-fbae-4046-9bff-4272834fac95	d3faa1bd-5b40-4e14-bd47-227d9f34f689	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-07 05:40:50.068864	route
0b23be55-8aad-4ac8-b62c-a7b9991f246d	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:28:47.241641	route
8a1f25ff-c20e-41f7-a6de-e0b818ad09c6	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:29:05.069695	route
5fd25865-4a85-422a-accd-c662889527d6	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-05 13:29:11.45125	route
b2649c53-04cf-4453-a6c1-d97605f83ca8	670871bb-6e48-431e-ae05-1b56663c0a7b	Shipment delayed	Shipment SHIP007 has been delayed after 24 hours in transit.	t	2026-09-05 13:10:00.308568	shipment
701f2242-7806-4027-a24b-e4ac9ab2ab4b	670871bb-6e48-431e-ae05-1b56663c0a7b	Maintenance scheduled	Maintenance for vehicle 97f9f879-0468-480c-bc9c-c38d79d004fd has been resolved.	t	2026-09-05 13:12:19.659944	maintenance
7328245a-e6af-423c-9951-927081dbcd95	670871bb-6e48-431e-ae05-1b56663c0a7b	5-day maintenance reminder: 233928dc-762b-4ee4-9d1d-e5118cce3545	Vehicle 9c23be6e-e1e4-48d3-b8d2-76be0456af32 is due for Break Failure maintenance in 5 days (2026-09-10T18:42:00).	t	2026-09-06 05:01:29.911018	maintenance
bd52aaa6-6679-4c4e-814e-0bf5dfae6539	670871bb-6e48-431e-ae05-1b56663c0a7b	Shipment delayed	Shipment SHIP008 has been delayed after 24 hours in transit.	t	2026-09-06 13:20:00.053964	shipment
aa7b1205-42c1-4ebf-9bfa-b65a306ea071	670871bb-6e48-431e-ae05-1b56663c0a7b	Route recalculated	Route for trip 2b178a09-ce2c-424a-89fb-5f87d3436539 was recalculated using Fastest Route.	t	2026-09-07 05:40:50.068834	route
\.


--
-- Data for Name: shipment_status_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipment_status_history (history_id, shipment_id, status, changed_at, changed_by_user_id) FROM stdin;
6d3211de-7691-442a-9831-9d168424f6fc	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:30:24.093014	670871bb-6e48-431e-ae05-1b56663c0a7b
388dba5b-9ff8-4728-a160-c8d3ecbba9d8	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:30:36.741264	670871bb-6e48-431e-ae05-1b56663c0a7b
3e4c886b-cb2f-4ee9-b895-8b46aa517743	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:31:07.850048	670871bb-6e48-431e-ae05-1b56663c0a7b
aea4c578-6998-48f8-989d-daf5334ea972	7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	Assigned	2026-08-28 12:31:46.105343	670871bb-6e48-431e-ae05-1b56663c0a7b
f6d0fc82-74b9-49f1-826f-04ac0552f9b9	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:31:54.873332	670871bb-6e48-431e-ae05-1b56663c0a7b
9595449e-601c-4c2e-b3ce-bafdd8cbea4e	7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	Assigned	2026-08-28 12:32:02.649604	670871bb-6e48-431e-ae05-1b56663c0a7b
b76ca172-27b1-4bb4-a697-736cf7059f58	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:56:23.067813	670871bb-6e48-431e-ae05-1b56663c0a7b
99f554d1-a132-40e8-8918-b0a99ffce1ab	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Assigned	2026-08-28 12:57:08.000649	670871bb-6e48-431e-ae05-1b56663c0a7b
a6f5f2be-a7c7-4d2c-9749-5e56cdfb6863	00394ed2-f0a6-448b-89b3-23642a34160b	Delivered	2026-08-29 16:12:21.072158	670871bb-6e48-431e-ae05-1b56663c0a7b
462197f1-797f-47d1-8572-e120b128729f	e32ee02d-a6de-4a58-bfdf-d36c1755c341	Assigned	2026-08-29 16:15:18.357722	670871bb-6e48-431e-ae05-1b56663c0a7b
86675096-122a-44a7-bfa5-22be25918d88	9fac4352-290d-402f-ad83-15dce13c9c4c	Assigned	2026-09-01 14:52:29.368056	d3faa1bd-5b40-4e14-bd47-227d9f34f689
0c0a8d33-57ab-4c47-91bc-f2c65d63689c	4b97ab02-a476-4f9c-b071-908c2c76605a	Assigned	2026-09-02 12:15:21.018744	d3faa1bd-5b40-4e14-bd47-227d9f34f689
c2f3caa5-3eab-49f8-bc32-277d1b33c8d6	4b97ab02-a476-4f9c-b071-908c2c76605a	In Transit	2026-09-05 13:10:15.877827	d3faa1bd-5b40-4e14-bd47-227d9f34f689
869ca2a5-4f1c-46a4-a91f-56f0ccdb7226	bc9337c5-249f-47f0-8f6e-183f332c0e99	Created	2026-09-05 13:11:43.342325	d3faa1bd-5b40-4e14-bd47-227d9f34f689
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipments (shipment_id, vehicle_id, driver_id, tracking_number, source, destination, status, eta, created_at, customer_name, shipment_weight, expected_delivery_at) FROM stdin;
4cbee132-e73e-4060-946a-75a5d3402974	\N	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	SHIP001	Hyderabad	Bangalore	Delivered	2026-08-02	2026-07-31 15:56:15.558921	\N	\N	\N
00394ed2-f0a6-448b-89b3-23642a34160b	\N	5f141cfc-3848-4337-9e00-59eec4d587a3	SHIP002	Proddatur	Kadapa	Delivered	2026-08-06	2026-08-04 12:45:46.121683	\N	\N	\N
f59304b4-03f0-4db2-b0cd-42c6a37afa79	\N	5f141cfc-3848-4337-9e00-59eec4d587a3	SHIP003	Allagadda	mydukuru	Delivered	2026-08-27	2026-08-28 12:30:24.076451	\N	\N	\N
e32ee02d-a6de-4a58-bfdf-d36c1755c341	\N	3c4164d3-133e-4711-93db-115ad295478e	SHIP005	Jammalamadugu	Pune	Delivered	2026-08-29	2026-08-29 16:15:18.341845	\N	\N	\N
9fac4352-290d-402f-ad83-15dce13c9c4c	\N	3c4164d3-133e-4711-93db-115ad295478e	SHIP006	Vijayawada	Tirupati	Delivered	2026-09-01	2026-09-01 14:52:29.354885	\N	\N	\N
7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	\N	45243140-5694-434e-816f-6bc238986524	SHIP004	Badvel	Nalgonda	Delivered	2026-08-28	2026-08-28 12:31:46.093788	\N	\N	\N
4b97ab02-a476-4f9c-b071-908c2c76605a	\N	68e44e79-6b17-4117-b72d-b4c1b89ad8c7	SHIP007	Proddatur	Visakhapatnam	Delivered	2026-09-02	2026-09-02 12:15:20.988112	\N	\N	\N
bc9337c5-249f-47f0-8f6e-183f332c0e99	\N	\N	SHIP008	Ongole	Nellore	Delayed	2026-09-05	2026-09-05 13:11:43.328958	\N	\N	\N
\.


--
-- Data for Name: trips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trips (trip_id, vehicle_id, driver_id, shipment_id, start_location, end_location, start_time, end_time, status, distance_km, actual_distance_km, duration_minutes, route_type, eta, remaining_distance_km) FROM stdin;
2b178a09-ce2c-424a-89fb-5f87d3436539	97f9f879-0468-480c-bc9c-c38d79d004fd	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	bc9337c5-249f-47f0-8f6e-183f332c0e99	Ongole	Nellore	2026-09-05 13:14:06.208913	\N	In Progress	128.65	\N	94	Fastest Route	2026-09-07 12:47:50.044849	\N
7b9ec0ac-6faa-4ee1-994b-c0e5ff02f9e7	b84072f3-0a48-4973-aa6e-b51be31b1b79	b9a6d64a-a57f-45ad-8292-4f1b10f8f8d9	4cbee132-e73e-4060-946a-75a5d3402974	Hyderabad	Bangalore	2026-08-21 10:41:07.101375	2026-08-21 10:41:08.996587	Completed	\N	\N	\N	\N	\N	\N
9ba7b7b8-8d0a-40b5-bbbe-c38d9408f851	b84072f3-0a48-4973-aa6e-b51be31b1b79	5f141cfc-3848-4337-9e00-59eec4d587a3	00394ed2-f0a6-448b-89b3-23642a34160b	proddatur	kadapa	2026-08-28 12:29:29.65485	2026-08-28 12:29:32.908406	Completed	52.35	\N	41	Fastest Route	2026-08-26 21:46:59.008094	\N
0d790a49-83f4-4331-a050-db7cfdf27299	80fc44dd-b051-4b5d-ba6c-db1c9cc5953f	5f141cfc-3848-4337-9e00-59eec4d587a3	f59304b4-03f0-4db2-b0cd-42c6a37afa79	Allagadda	mydukuru	2026-08-29 16:16:03.161733	2026-08-31 12:17:53.551186	Completed	52.43	\N	39	Fastest Route	2026-08-28 19:11:15.629209	\N
e0178854-739f-48c7-8403-d4e2fcf5d8ab	9c23be6e-e1e4-48d3-b8d2-76be0456af32	3c4164d3-133e-4711-93db-115ad295478e	e32ee02d-a6de-4a58-bfdf-d36c1755c341	Jammalamadugu	Pune	2026-08-31 12:17:57.531261	2026-09-01 14:46:06.275877	Completed	\N	\N	\N	Fastest Route	\N	\N
ab2a769c-6f11-4f08-b078-ca01b3f08dff	69e0ccec-aa38-449a-991b-39bbac7dedcc	3c4164d3-133e-4711-93db-115ad295478e	9fac4352-290d-402f-ad83-15dce13c9c4c	Vijayawada	Tirupati	2026-09-02 12:14:34.721845	2026-09-02 12:14:37.252402	Completed	\N	\N	\N	Fastest Route	\N	\N
13ff480c-fb98-4b61-be95-901e52a68023	e8730316-9126-485f-9dac-ceca230b2ab3	45243140-5694-434e-816f-6bc238986524	7aa81b4c-0b72-4c4c-9a8e-1c6f6f6ef291	Badvel	Nalgonda	2026-09-01 14:53:56.511376	2026-09-05 13:05:41.413906	Completed	302.62	\N	230	Fastest Route	2026-09-03 01:42:24.266014	\N
f98780fe-763c-4cb2-a3fc-e68e0055c30e	b84072f3-0a48-4973-aa6e-b51be31b1b79	d97a46a8-c59f-4bbf-8914-cbbc8707ae85	4b97ab02-a476-4f9c-b071-908c2c76605a	Proddatur	Vishakapatnam	2026-09-03 13:05:25.022474	2026-09-05 13:10:42.617903	Completed	\N	\N	\N	Fastest Route	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, full_name, email, password, phone, role, created_at, updated_at, email_verified, verification_code, verification_code_expires_at, address) FROM stdin;
bb493577-cc3c-4b49-b8f3-98ccd4fb464d	Revanth Reddy	revanth8638@gmail.com	$2b$12$yDDJmM9PMLHufR7E.Zs/Qe4Eu3gVFEjiyz44RVE.deBfaCvqHD5Dq	8639526641	FleetManager	2026-08-03 14:56:54.75597	2026-08-03 14:56:54.755981	f	\N	\N	\N
670871bb-6e48-431e-ae05-1b56663c0a7b	Revanth Reddy	revanth8639@gmail.com	$2b$12$mI5UMw8pnFZ0FyMPQ9ejqeELhKfRK0MCZmbpEXhjh63jSVa/HseA6	8639526641	FleetManager	2026-08-04 10:38:12.484061	2026-08-04 10:38:12.484066	f	\N	\N	\N
c0d7885a-11cc-4dad-a5ba-c2d964b3a51d	manohar	manoharmanohar52808@gmail.com	$2b$12$86lngwZnVce8XOQrOzDOPuftZryj3478FWaWBnLVj/IhH3v6wjvZ.	8978456290	Driver	2026-08-10 17:14:44.928233	2026-08-10 17:14:44.928242	f	\N	\N	\N
d3faa1bd-5b40-4e14-bd47-227d9f34f689	Uday Kiran Reddy	vennapusauday.aiml@sandipuniversity.edu.in	$2b$12$bMJU4rEYKyg5LT7WeJSpDuFKrMyWfOis.lODusPCOLLM5sdIqrP6G	7416818182	Admin	2026-08-26 15:40:36.760652	2026-08-26 15:40:36.760657	f	\N	\N	\N
b43b5ce8-f3b4-49a3-be5b-e2da2541764e	Dhanireddy	reddydhani8639@gmail.com	$2b$12$Ua.KkI2TCJ1VYFbYwXXq.OoYqBt05zD4P7Qax90lxeSOjsRFpgXW6	8639526641	Dispatcher	2026-08-26 15:44:38.085846	2026-08-26 15:44:38.08585	f	\N	\N	\N
676cf171-d65a-47bd-bfda-fdcef73439cc	Kiran Reddy	vukreddy943@gmail.com	$2b$12$Ww6p7Wk1sfzBPYXOp89nJOhNhRTyrMHnt9uDty17yhsBUqMdC5Oii	7416818182	Driver	2026-08-29 13:10:59.220161	2026-08-29 13:10:59.220164	f	\N	\N	\N
\.


--
-- Data for Name: vehicle_maintenance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicle_maintenance (maintenance_id, vehicle_id, service_type, description, service_date, next_service_date, cost, status) FROM stdin;
f362ccbf-24bf-4e5c-b174-dabf852cd8ce	e8730316-9126-485f-9dac-ceca230b2ab3	Oil change		2026-08-10 14:44:31.371068	2026-08-21 20:14:00	12580	Completed
055480bd-4156-4829-8b88-5aa4b2a8170d	b84072f3-0a48-4973-aa6e-b51be31b1b79	servicing		2026-08-26 15:01:07.315234	2026-08-26 20:30:00	5500	Completed
68049d4b-f0af-47e4-b43b-63b15e6a5951	97f9f879-0468-480c-bc9c-c38d79d004fd	Changing tyres		2026-08-28 05:29:47.231481	2026-08-24 10:59:00	36258	Completed
233928dc-762b-4ee4-9d1d-e5118cce3545	9c23be6e-e1e4-48d3-b8d2-76be0456af32	Break Failure		2026-09-05 18:42:00	2026-09-05 18:42:00	28352	In Progress
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (vehicle_id, registration_number, vehicle_type, capacity, fuel_type, status, created_at, brand, model, manufacture_year, assigned_driver_id) FROM stdin;
80fc44dd-b051-4b5d-ba6c-db1c9cc5953f	AP40AJ2567	Container	40 Tons	Diesel	Available	2026-08-28 04:46:06.900086	\N	\N	\N	\N
69e0ccec-aa38-449a-991b-39bbac7dedcc	AP40NP6641	Container	43 Tons	Diesel	Available	2026-09-01 14:51:11.208191	\N	\N	\N	\N
e8730316-9126-485f-9dac-ceca230b2ab3	AP39HP9296	Truck	10 Toons	Diesel	Available	2026-08-10 11:29:33.777825	\N	\N	\N	\N
b84072f3-0a48-4973-aa6e-b51be31b1b79	AP39AB1235	Truck	10 Tons	Diesel	Available	2026-08-01 11:12:01.756063	\N	\N	\N	\N
9c23be6e-e1e4-48d3-b8d2-76be0456af32	AP04BP2398	Container	45 Tons	Diesel	Maintenance	2026-08-28 04:54:40.366708	\N	\N	\N	68e44e79-6b17-4117-b72d-b4c1b89ad8c7
97f9f879-0468-480c-bc9c-c38d79d004fd	AP40DP8639	Truck	35 Tons	Electric	In Transit	2026-08-28 04:53:41.603354	\N	\N	\N	\N
\.


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (activity_id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (driver_id);


--
-- Name: drivers drivers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_user_id_key UNIQUE (user_id);


--
-- Name: email_otps email_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_otps
    ADD CONSTRAINT email_otps_pkey PRIMARY KEY (email);


--
-- Name: fuel_records fuel_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_records
    ADD CONSTRAINT fuel_records_pkey PRIMARY KEY (fuel_id);


--
-- Name: gps_tracking gps_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gps_tracking
    ADD CONSTRAINT gps_tracking_pkey PRIMARY KEY (tracking_id);


--
-- Name: job_runs job_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT job_runs_pkey PRIMARY KEY (run_id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (leave_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: shipment_status_history shipment_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_status_history
    ADD CONSTRAINT shipment_status_history_pkey PRIMARY KEY (history_id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (shipment_id);


--
-- Name: shipments shipments_tracking_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_tracking_number_key UNIQUE (tracking_number);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- Name: attendance uq_attendance_driver_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT uq_attendance_driver_date UNIQUE (driver_id, date);


--
-- Name: drivers uq_drivers_vehicle_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT uq_drivers_vehicle_id UNIQUE (vehicle_id);


--
-- Name: vehicles uq_vehicles_assigned_driver; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT uq_vehicles_assigned_driver UNIQUE (assigned_driver_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vehicle_maintenance vehicle_maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_maintenance
    ADD CONSTRAINT vehicle_maintenance_pkey PRIMARY KEY (maintenance_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_registration_number_key UNIQUE (registration_number);


--
-- Name: ix_activity_logs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_activity_logs_created_at ON public.activity_logs USING btree (created_at);


--
-- Name: ix_job_runs_task_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_job_runs_task_name ON public.job_runs USING btree (task_name);


--
-- Name: ix_shipment_status_history_shipment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_shipment_status_history_shipment_id ON public.shipment_status_history USING btree (shipment_id);


--
-- Name: ix_shipments_customer_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_shipments_customer_name ON public.shipments USING btree (customer_name);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: activity_logs activity_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: attendance attendance_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: drivers drivers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: drivers fk_drivers_vehicle_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT fk_drivers_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: vehicles fk_vehicles_assigned_driver; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_vehicles_assigned_driver FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: fuel_records fuel_records_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_records
    ADD CONSTRAINT fuel_records_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: gps_tracking gps_tracking_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gps_tracking
    ADD CONSTRAINT gps_tracking_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: leave_requests leave_requests_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: leave_requests leave_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(user_id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: shipment_status_history shipment_status_history_changed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_status_history
    ADD CONSTRAINT shipment_status_history_changed_by_user_id_fkey FOREIGN KEY (changed_by_user_id) REFERENCES public.users(user_id);


--
-- Name: shipment_status_history shipment_status_history_shipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_status_history
    ADD CONSTRAINT shipment_status_history_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(shipment_id);


--
-- Name: shipments shipments_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: shipments shipments_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: trips trips_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: trips trips_shipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(shipment_id);


--
-- Name: trips trips_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: vehicle_maintenance vehicle_maintenance_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_maintenance
    ADD CONSTRAINT vehicle_maintenance_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 5HC0Nr4olNusxAB88xTIkP3ichqhJMk1y7REG3Im8l5If3hfi1g5bPcckDXzhe3

