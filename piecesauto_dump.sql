--
-- PostgreSQL database dump
--

\restrict UnSH1XGXPeOrBBlrtuA1BrksWQVc98mczbEefDormzsuYBrWiE0nEYagEIuZbUG

-- Dumped from database version 18.4 (Debian 18.4-1)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id integer NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    password_salt text NOT NULL,
    name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL,
    slug text NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer,
    title text NOT NULL,
    reference text,
    unit_cents integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: order_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    order_number text NOT NULL,
    customer_name text NOT NULL,
    customer_email text NOT NULL,
    customer_phone text,
    address_line text NOT NULL,
    postal_code text NOT NULL,
    city text NOT NULL,
    country text DEFAULT 'France'::text NOT NULL,
    payment_method text NOT NULL,
    status text DEFAULT 'en_attente'::text NOT NULL,
    total_cents integer DEFAULT 0 NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    invoiced_at timestamp with time zone,
    CONSTRAINT orders_payment_method_check CHECK ((payment_method = ANY (ARRAY['virement'::text, 'cheque'::text, 'livraison'::text, 'especes'::text])))
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_categories (
    product_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id integer NOT NULL,
    product_id integer NOT NULL,
    url text NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    reference text,
    brand text,
    price_cents integer DEFAULT 0 NOT NULL,
    currency text DEFAULT 'EUR'::text NOT NULL,
    short_desc text,
    long_desc text,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    stock_status text DEFAULT 'en_stock'::text NOT NULL,
    source_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: product_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, email, password_hash, password_salt, name, created_at) FROM stdin;
1	admin@piecesauto.fr	976a9bfa7fb2ce8eedcccbd09e9dc741a107856c4cf52e8fdcf89a877713c0d6a49a4f6223e12e424668b4d8a6b9598cdd228ad313299eb27bc9a535d66a0217	997e06efe826f8deb62fa4fa52f7e605	Ulrich	2026-07-07 03:04:02.090444+02
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, slug) FROM stdin;
1	Entretien & Nettoyage	entretien-nettoyage
2	Accessoires d’entretien	accessoires-d-entretien
3	Nettoyage extérieur	nettoyage-exterieur
4	Nettoyage intérieur	nettoyage-interieur
5	Spécial motards	special-motards
6	Sprays techniques, Dégrippants & Graisses	sprays-techniques-degrippants-graisses
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, title, reference, unit_cents, quantity) FROM stdin;
1	1	62	Anti usure boite de vitesse manuelle – Bardahl	1045	2890	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, order_number, customer_name, customer_email, customer_phone, address_line, postal_code, city, country, payment_method, status, total_cents, note, created_at, invoiced_at) FROM stdin;
1	CMD-2026-000001	ulrich	ulrich@gmail.com	5666543456788990	FRDEDG	RRTE668	yde	France	virement	en_attente	2890	\N	2026-07-07 02:48:44.971476+02	\N
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_categories (product_id, category_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
2	1
2	2
2	3
2	4
2	5
2	6
3	1
3	2
3	3
3	4
3	5
3	6
4	1
4	2
4	3
4	4
4	5
4	6
5	1
5	2
5	3
5	4
5	5
5	6
6	1
6	2
6	3
6	4
6	5
6	6
7	1
7	2
7	3
7	4
7	5
7	6
8	1
8	2
8	3
8	4
8	5
8	6
9	1
9	2
9	3
9	4
9	5
9	6
10	1
10	2
10	3
10	4
10	5
10	6
11	1
11	2
11	3
11	4
11	5
11	6
12	1
12	2
12	3
12	4
12	5
12	6
13	1
13	2
13	3
13	4
13	5
13	6
14	1
14	2
14	3
14	4
14	5
14	6
15	1
15	2
15	3
15	4
15	5
15	6
16	1
16	2
16	3
16	4
16	5
16	6
17	1
17	2
17	3
17	4
17	5
17	6
18	1
18	2
18	3
18	4
18	5
18	6
19	1
19	2
19	3
19	4
19	5
19	6
20	1
20	2
20	3
20	4
20	5
20	6
21	1
21	2
21	3
21	4
21	5
21	6
22	1
22	2
22	3
22	4
22	5
22	6
23	1
23	2
23	3
23	4
23	5
23	6
24	1
24	2
24	3
24	4
24	5
24	6
25	1
25	2
25	3
25	4
25	5
25	6
26	1
26	2
26	3
26	4
26	5
26	6
27	1
27	2
27	3
27	4
27	5
27	6
28	1
28	2
28	3
28	4
28	5
28	6
29	1
29	2
29	3
29	4
29	5
29	6
30	1
30	2
30	3
30	4
30	5
30	6
31	1
31	2
31	3
31	4
31	5
31	6
32	1
32	2
32	3
32	4
32	5
32	6
33	1
33	2
33	3
33	4
33	5
33	6
34	1
34	2
34	3
34	4
34	5
34	6
35	1
35	2
35	3
35	4
35	5
35	6
36	1
36	2
36	3
36	4
36	5
36	6
37	1
37	2
37	3
37	4
37	5
37	6
38	1
38	2
38	3
38	4
38	5
38	6
39	1
39	2
39	3
39	4
39	5
39	6
40	1
40	2
40	3
40	4
40	5
40	6
41	1
41	2
41	3
41	4
41	5
41	6
42	1
42	2
42	3
42	4
42	5
42	6
43	1
43	2
43	3
43	4
43	5
43	6
44	1
44	2
44	3
44	4
44	5
44	6
45	1
45	2
45	3
45	4
45	5
45	6
46	1
46	2
46	3
46	4
46	5
46	6
47	1
47	2
47	3
47	4
47	5
47	6
48	1
48	2
48	3
48	4
48	5
48	6
49	1
49	2
49	3
49	4
49	5
49	6
50	1
50	2
50	3
50	4
50	5
50	6
51	1
51	2
51	3
51	4
51	5
51	6
52	1
52	2
52	3
52	4
52	5
52	6
53	1
53	2
53	3
53	4
53	5
53	6
54	1
54	2
54	3
54	4
54	5
54	6
55	1
55	2
55	3
55	4
55	5
55	6
56	1
56	2
56	3
56	4
56	5
56	6
57	1
57	2
57	3
57	4
57	5
57	6
58	1
58	2
58	3
58	4
58	5
58	6
59	1
59	2
59	3
59	4
59	5
59	6
60	1
60	2
60	3
60	4
60	5
60	6
61	1
61	2
61	3
61	4
61	5
61	6
62	1
62	2
62	3
62	4
62	5
62	6
63	1
63	2
63	3
63	4
63	5
63	6
64	1
64	2
64	3
64	4
64	5
64	6
65	1
65	2
65	3
65	4
65	5
65	6
66	1
66	2
66	3
66	4
66	5
66	6
67	1
67	2
67	3
67	4
67	5
67	6
68	1
68	2
68	3
68	4
68	5
68	6
69	1
69	2
69	3
69	4
69	5
69	6
70	1
70	2
70	3
70	4
70	5
70	6
71	1
71	2
71	3
71	4
71	5
71	6
72	1
72	2
72	3
72	4
72	5
72	6
73	1
73	2
73	3
73	4
73	5
73	6
74	1
74	2
74	3
74	4
74	5
74	6
75	1
75	2
75	3
75	4
75	5
75	6
76	1
76	2
76	3
76	4
76	5
76	6
77	1
77	2
77	3
77	4
77	5
77	6
78	1
78	2
78	3
78	4
78	5
78	6
79	1
79	2
79	3
79	4
79	5
79	6
80	1
80	2
80	3
80	4
80	5
80	6
81	1
81	2
81	3
81	4
81	5
81	6
82	1
82	2
82	3
82	4
82	5
82	6
83	1
83	2
83	3
83	4
83	5
83	6
84	1
84	2
84	3
84	4
84	5
84	6
85	1
85	2
85	3
85	4
85	5
85	6
86	1
86	2
86	3
86	4
86	5
86	6
87	1
87	2
87	3
87	4
87	5
87	6
88	1
88	2
88	3
88	4
88	5
88	6
89	1
89	2
89	3
89	4
89	5
89	6
90	1
90	2
90	3
90	4
90	5
90	6
91	1
91	2
91	3
91	4
91	5
91	6
92	1
92	2
92	3
92	4
92	5
92	6
93	1
93	2
93	3
93	4
93	5
93	6
94	1
94	2
94	3
94	4
94	5
94	6
95	1
95	2
95	3
95	4
95	5
95	6
96	1
96	2
96	3
96	4
96	5
96	6
97	1
97	2
97	3
97	4
97	5
97	6
98	1
98	2
98	3
98	4
98	5
98	6
99	1
99	2
99	3
99	4
99	5
99	6
100	1
100	2
100	3
100	4
100	5
100	6
101	1
101	2
101	3
101	4
101	5
101	6
102	1
102	2
102	3
102	4
102	5
102	6
103	1
103	2
103	3
103	4
103	5
103	6
104	1
104	2
104	3
104	4
104	5
104	6
105	1
105	2
105	3
105	4
105	5
105	6
106	1
106	2
106	3
106	4
106	5
106	6
107	1
107	2
107	3
107	4
107	5
107	6
108	1
108	2
108	3
108	4
108	5
108	6
109	1
109	2
109	3
109	4
109	5
109	6
110	1
110	2
110	3
110	4
110	5
110	6
111	1
111	2
111	3
111	4
111	5
111	6
112	1
112	2
112	3
112	4
112	5
112	6
113	1
113	2
113	3
113	4
113	5
113	6
114	1
114	2
114	3
114	4
114	5
114	6
115	1
115	2
115	3
115	4
115	5
115	6
116	1
116	2
116	3
116	4
116	5
116	6
117	1
117	2
117	3
117	4
117	5
117	6
118	1
118	2
118	3
118	4
118	5
118	6
119	1
119	2
119	3
119	4
119	5
119	6
120	1
120	2
120	3
120	4
120	5
120	6
121	1
121	2
121	3
121	4
121	5
121	6
122	1
122	2
122	3
122	4
122	5
122	6
123	1
123	2
123	3
123	4
123	5
123	6
124	1
124	2
124	3
124	4
124	5
124	6
125	1
125	2
125	3
125	4
125	5
125	6
126	1
126	2
126	3
126	4
126	5
126	6
127	1
127	2
127	3
127	4
127	5
127	6
128	1
128	2
128	3
128	4
128	5
128	6
129	1
129	2
129	3
129	4
129	5
129	6
130	1
130	2
130	3
130	4
130	5
130	6
131	1
131	2
131	3
131	4
131	5
131	6
132	1
132	2
132	3
132	4
132	5
132	6
133	1
133	2
133	3
133	4
133	5
133	6
134	1
134	2
134	3
134	4
134	5
134	6
135	1
135	2
135	3
135	4
135	5
135	6
136	1
136	2
136	3
136	4
136	5
136	6
137	1
137	2
137	3
137	4
137	5
137	6
138	1
138	2
138	3
138	4
138	5
138	6
139	1
139	2
139	3
139	4
139	5
139	6
140	1
140	2
140	3
140	4
140	5
140	6
141	1
141	2
141	3
141	4
141	5
141	6
142	1
142	2
142	3
142	4
142	5
142	6
143	1
143	2
143	3
143	4
143	5
143	6
144	1
144	2
144	3
144	4
144	5
144	6
145	1
145	2
145	3
145	4
145	5
145	6
146	1
146	2
146	3
146	4
146	5
146	6
147	1
147	2
147	3
147	4
147	5
147	6
148	1
148	2
148	3
148	4
148	5
148	6
149	1
149	2
149	3
149	4
149	5
149	6
150	1
150	2
150	3
150	4
150	5
150	6
151	1
151	2
151	3
151	4
151	5
151	6
152	1
152	2
152	3
152	4
152	5
152	6
153	1
153	2
153	3
153	4
153	5
153	6
154	1
154	2
154	3
154	4
154	5
154	6
155	1
155	2
155	3
155	4
155	5
155	6
156	1
156	2
156	3
156	4
156	5
156	6
157	1
157	2
157	3
157	4
157	5
157	6
158	1
158	2
158	3
158	4
158	5
158	6
159	1
159	2
159	3
159	4
159	5
159	6
160	1
160	2
160	3
160	4
160	5
160	6
161	1
161	2
161	3
161	4
161	5
161	6
162	1
162	2
162	3
162	4
162	5
162	6
163	1
163	2
163	3
163	4
163	5
163	6
164	1
164	2
164	3
164	4
164	5
164	6
165	1
165	2
165	3
165	4
165	5
165	6
166	1
166	2
166	3
166	4
166	5
166	6
167	1
167	2
167	3
167	4
167	5
167	6
168	1
168	2
168	3
168	4
168	5
168	6
169	1
169	2
169	3
169	4
169	5
169	6
170	1
170	2
170	3
170	4
170	5
170	6
171	1
171	2
171	3
171	4
171	5
171	6
172	1
172	2
172	3
172	4
172	5
172	6
173	1
173	2
173	3
173	4
173	5
173	6
174	1
174	2
174	3
174	4
174	5
174	6
175	1
175	2
175	3
175	4
175	5
175	6
176	1
176	2
176	3
176	4
176	5
176	6
177	1
177	2
177	3
177	4
177	5
177	6
178	1
178	2
178	3
178	4
178	5
178	6
179	1
179	2
179	3
179	4
179	5
179	6
180	1
180	2
180	3
180	4
180	5
180	6
181	1
181	2
181	3
181	4
181	5
181	6
182	1
182	2
182	3
182	4
182	5
182	6
183	1
183	2
183	3
183	4
183	5
183	6
184	1
184	2
184	3
184	4
184	5
184	6
185	1
185	2
185	3
185	4
185	5
185	6
186	1
186	2
186	3
186	4
186	5
186	6
187	1
187	2
187	3
187	4
187	5
187	6
188	1
188	2
188	3
188	4
188	5
188	6
189	1
189	2
189	3
189	4
189	5
189	6
190	1
190	2
190	3
190	4
190	5
190	6
191	1
191	2
191	3
191	4
191	5
191	6
192	1
192	2
192	3
192	4
192	5
192	6
193	1
193	2
193	3
193	4
193	5
193	6
194	1
194	2
194	3
194	4
194	5
194	6
195	1
195	2
195	3
195	4
195	5
195	6
196	1
196	2
196	3
196	4
196	5
196	6
197	1
197	2
197	3
197	4
197	5
197	6
198	1
198	2
198	3
198	4
198	5
198	6
199	1
199	2
199	3
199	4
199	5
199	6
200	1
200	2
200	3
200	4
200	5
200	6
201	1
201	2
201	3
201	4
201	5
201	6
202	1
202	2
202	3
202	4
202	5
202	6
203	1
203	2
203	3
203	4
203	5
203	6
204	1
204	2
204	3
204	4
204	5
204	6
205	1
205	2
205	3
205	4
205	5
205	6
206	1
206	2
206	3
206	4
206	5
206	6
207	1
207	2
207	3
207	4
207	5
207	6
208	1
208	2
208	3
208	4
208	5
208	6
209	1
209	2
209	3
209	4
209	5
209	6
210	1
210	2
210	3
210	4
210	5
210	6
211	1
211	2
211	3
211	4
211	5
211	6
212	1
212	2
212	3
212	4
212	5
212	6
213	1
213	2
213	3
213	4
213	5
213	6
214	1
214	2
214	3
214	4
214	5
214	6
215	1
215	2
215	3
215	4
215	5
215	6
216	1
216	2
216	3
216	4
216	5
216	6
217	1
217	2
217	3
217	4
217	5
217	6
218	1
218	2
218	3
218	4
218	5
218	6
219	1
219	2
219	3
219	4
219	5
219	6
220	1
220	2
220	3
220	4
220	5
220	6
221	1
221	2
221	3
221	4
221	5
221	6
222	1
222	2
222	3
222	4
222	5
222	6
223	1
223	2
223	3
223	4
223	5
223	6
224	1
224	2
224	3
224	4
224	5
224	6
225	1
225	2
225	3
225	4
225	5
225	6
226	1
226	2
226	3
226	4
226	5
226	6
227	1
227	2
227	3
227	4
227	5
227	6
228	1
228	2
228	3
228	4
228	5
228	6
229	1
229	2
229	3
229	4
229	5
229	6
230	1
230	2
230	3
230	4
230	5
230	6
231	1
231	2
231	3
231	4
231	5
231	6
232	1
232	2
232	3
232	4
232	5
232	6
233	1
233	2
233	3
233	4
233	5
233	6
234	1
234	2
234	3
234	4
234	5
234	6
235	1
235	2
235	3
235	4
235	5
235	6
236	1
236	2
236	3
236	4
236	5
236	6
237	1
237	2
237	3
237	4
237	5
237	6
238	1
238	2
238	3
238	4
238	5
238	6
239	1
239	2
239	3
239	4
239	5
239	6
240	1
240	2
240	3
240	4
240	5
240	6
241	1
241	2
241	3
241	4
241	5
241	6
242	1
242	2
242	3
242	4
242	5
242	6
243	1
243	2
243	3
243	4
243	5
243	6
244	1
244	2
244	3
244	4
244	5
244	6
245	1
245	2
245	3
245	4
245	5
245	6
246	1
246	2
246	3
246	4
246	5
246	6
247	1
247	2
247	3
247	4
247	5
247	6
248	1
248	2
248	3
248	4
248	5
248	6
249	1
249	2
249	3
249	4
249	5
249	6
250	1
250	2
250	3
250	4
250	5
250	6
251	1
251	2
251	3
251	4
251	5
251	6
252	1
252	2
252	3
252	4
252	5
252	6
253	1
253	2
253	3
253	4
253	5
253	6
254	1
254	2
254	3
254	4
254	5
254	6
255	1
255	2
255	3
255	4
255	5
255	6
256	1
256	2
256	3
256	4
256	5
256	6
257	1
257	2
257	3
257	4
257	5
257	6
258	1
258	2
258	3
258	4
258	5
258	6
259	1
259	2
259	3
259	4
259	5
259	6
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_images (id, product_id, url, "position") FROM stdin;
9	2	/media/2/3.jpg	3
10	2	/media/2/4.png	4
11	3	/media/3/0.jpg	0
12	3	/media/3/1.jpg	1
13	3	/media/3/2.jpg	2
14	3	/media/3/3.png	3
15	4	/media/4/0.jpg	0
16	4	/media/4/1.jpg	1
17	4	/media/4/2.jpg	2
18	4	/media/4/3.jpg	3
19	4	/media/4/4.png	4
20	5	/media/5/0.jpg	0
21	5	/media/5/1.png	1
22	6	/media/6/0.jpg	0
23	6	/media/6/1.png	1
24	7	/media/7/0.jpg	0
25	7	/media/7/1.jpg	1
26	7	/media/7/2.jpg	2
27	7	/media/7/3.jpg	3
28	7	/media/7/4.jpg	4
29	7	/media/7/5.jpg	5
30	8	/media/8/0.jpg	0
31	8	/media/8/1.jpg	1
41	10	/media/10/0.jpg	0
42	10	/media/10/1.jpg	1
43	10	/media/10/2.png	2
44	11	/media/11/0.jpg	0
45	11	/media/11/1.jpg	1
46	11	/media/11/2.png	2
47	12	/media/12/0.jpg	0
48	12	/media/12/1.jpg	1
49	12	/media/12/2.png	2
50	13	/media/13/0.jpg	0
51	13	/media/13/1.jpg	1
52	13	/media/13/2.jpg	2
53	13	/media/13/3.jpg	3
54	13	/media/13/4.jpg	4
55	13	/media/13/5.jpg	5
56	14	/media/14/0.jpg	0
57	14	/media/14/1.jpg	1
58	14	/media/14/2.jpg	2
59	14	/media/14/3.png	3
60	15	/media/15/0.jpg	0
61	15	/media/15/1.jpg	1
62	15	/media/15/2.jpg	2
63	15	/media/15/3.jpg	3
64	15	/media/15/4.jpg	4
65	15	/media/15/5.jpg	5
3	1	/media/1/2.jpg	2
4	1	/media/1/3.jpg	3
5	1	/media/1/4.png	4
6	2	/media/2/0.jpg	0
7	2	/media/2/1.jpg	1
32	8	/media/8/2.jpg	2
33	8	/media/8/3.jpg	3
34	8	/media/8/4.jpg	4
35	8	/media/8/5.jpg	5
36	9	/media/9/0.jpg	0
37	9	/media/9/1.jpg	1
38	9	/media/9/2.jpg	2
39	9	/media/9/3.jpg	3
40	9	/media/9/4.png	4
1	1	/media/1/0.jpg	0
2	1	/media/1/1.jpg	1
67	16	/media/16/1.jpg	1
68	16	/media/16/2.jpg	2
69	16	/media/16/3.jpg	3
70	16	/media/16/4.jpg	4
71	16	/media/16/5.jpg	5
72	17	/media/17/0.jpg	0
73	17	/media/17/1.jpg	1
74	17	/media/17/2.jpg	2
75	17	/media/17/3.jpg	3
76	17	/media/17/4.jpg	4
77	17	/media/17/5.jpg	5
78	18	/media/18/0.jpg	0
79	18	/media/18/1.jpg	1
80	18	/media/18/2.jpg	2
81	18	/media/18/3.jpg	3
82	18	/media/18/4.jpg	4
83	18	/media/18/5.jpg	5
84	19	/media/19/0.jpg	0
85	19	/media/19/1.jpg	1
86	19	/media/19/2.jpg	2
87	19	/media/19/3.jpg	3
88	19	/media/19/4.jpg	4
89	19	/media/19/5.jpg	5
90	20	/media/20/0.jpg	0
91	20	/media/20/1.jpg	1
92	20	/media/20/2.png	2
93	21	/media/21/0.jpg	0
94	21	/media/21/1.jpg	1
95	21	/media/21/2.jpg	2
96	21	/media/21/3.png	3
97	22	/media/22/0.jpg	0
98	22	/media/22/1.jpg	1
99	22	/media/22/2.jpg	2
100	22	/media/22/3.png	3
101	23	/media/23/0.jpg	0
102	23	/media/23/1.png	1
103	24	/media/24/0.jpg	0
104	24	/media/24/1.png	1
105	25	/media/25/0.jpg	0
106	25	/media/25/1.jpg	1
107	25	/media/25/2.png	2
108	26	/media/26/0.jpg	0
109	26	/media/26/1.png	1
110	27	/media/27/0.jpg	0
111	27	/media/27/1.png	1
112	28	/media/28/0.jpg	0
113	28	/media/28/1.jpg	1
114	28	/media/28/2.jpg	2
115	28	/media/28/3.png	3
116	29	/media/29/0.jpg	0
117	29	/media/29/1.jpg	1
118	29	/media/29/2.jpg	2
119	29	/media/29/3.png	3
120	29	/media/29/4.jpg	4
121	30	/media/30/0.jpg	0
122	30	/media/30/1.jpg	1
123	30	/media/30/2.jpg	2
124	30	/media/30/3.jpg	3
125	30	/media/30/4.jpg	4
126	30	/media/30/5.png	5
127	31	/media/31/0.jpg	0
128	31	/media/31/1.jpg	1
129	31	/media/31/2.png	2
130	32	/media/32/0.jpg	0
131	32	/media/32/1.jpg	1
132	32	/media/32/2.png	2
133	33	/media/33/0.jpg	0
134	33	/media/33/1.jpg	1
136	34	/media/34/0.jpg	0
137	34	/media/34/1.jpg	1
138	34	/media/34/2.jpg	2
139	34	/media/34/3.png	3
140	35	/media/35/0.jpg	0
141	35	/media/35/1.png	1
142	36	/media/36/0.jpg	0
143	36	/media/36/1.jpg	1
144	36	/media/36/2.jpg	2
145	36	/media/36/3.png	3
146	37	/media/37/0.jpg	0
147	37	/media/37/1.jpg	1
148	37	/media/37/2.png	2
149	38	/media/38/0.jpg	0
150	38	/media/38/1.jpg	1
151	38	/media/38/2.jpg	2
152	38	/media/38/3.jpg	3
153	38	/media/38/4.jpg	4
154	38	/media/38/5.jpg	5
155	39	/media/39/0.jpg	0
156	39	/media/39/1.png	1
157	40	/media/40/0.jpg	0
158	40	/media/40/1.jpg	1
159	40	/media/40/2.jpg	2
160	40	/media/40/3.png	3
161	41	/media/41/0.jpg	0
162	41	/media/41/1.jpg	1
163	41	/media/41/2.png	2
164	42	/media/42/0.jpg	0
165	42	/media/42/1.jpg	1
166	42	/media/42/2.jpg	2
167	42	/media/42/3.jpg	3
168	42	/media/42/4.png	4
169	43	/media/43/0.jpg	0
170	43	/media/43/1.jpg	1
171	43	/media/43/2.jpg	2
172	43	/media/43/3.jpg	3
173	43	/media/43/4.png	4
174	44	/media/44/0.jpg	0
175	44	/media/44/1.png	1
176	45	/media/45/0.jpg	0
177	45	/media/45/1.jpg	1
178	45	/media/45/2.jpg	2
179	45	/media/45/3.jpg	3
180	45	/media/45/4.png	4
181	46	/media/46/0.jpg	0
182	46	/media/46/1.jpg	1
183	46	/media/46/2.jpg	2
184	46	/media/46/3.png	3
185	47	/media/47/0.jpg	0
186	47	/media/47/1.png	1
187	48	/media/48/0.jpg	0
188	48	/media/48/1.jpg	1
189	48	/media/48/2.jpg	2
190	48	/media/48/3.png	3
191	49	/media/49/0.jpg	0
192	49	/media/49/1.jpg	1
193	49	/media/49/2.jpg	2
194	49	/media/49/3.png	3
195	50	/media/50/0.jpg	0
196	50	/media/50/1.jpg	1
197	50	/media/50/2.jpg	2
198	50	/media/50/3.jpg	3
199	50	/media/50/4.png	4
200	51	/media/51/0.png	0
201	51	/media/51/1.jpg	1
202	52	/media/52/0.jpg	0
204	53	/media/53/0.jpg	0
205	53	/media/53/1.jpg	1
206	53	/media/53/2.jpg	2
207	53	/media/53/3.jpg	3
208	53	/media/53/4.jpg	4
209	53	/media/53/5.png	5
210	54	/media/54/0.jpg	0
211	54	/media/54/1.jpg	1
212	54	/media/54/2.jpg	2
213	54	/media/54/3.png	3
214	55	/media/55/0.png	0
215	55	/media/55/1.jpg	1
216	56	/media/56/0.jpg	0
217	56	/media/56/1.jpg	1
218	56	/media/56/2.jpg	2
219	56	/media/56/3.png	3
220	57	/media/57/0.jpg	0
221	57	/media/57/1.jpg	1
222	57	/media/57/2.png	2
223	58	/media/58/0.jpg	0
224	58	/media/58/1.png	1
225	59	/media/59/0.jpg	0
226	59	/media/59/1.png	1
227	60	/media/60/0.jpg	0
228	60	/media/60/1.png	1
229	61	/media/61/0.jpg	0
230	61	/media/61/1.png	1
231	62	/media/62/0.png	0
232	62	/media/62/1.png	1
233	63	/media/63/0.png	0
234	63	/media/63/1.png	1
235	64	/media/64/0.jpg	0
236	64	/media/64/1.png	1
237	65	/media/65/0.png	0
238	65	/media/65/1.png	1
239	66	/media/66/0.jpg	0
240	66	/media/66/1.png	1
241	67	/media/67/0.jpg	0
242	67	/media/67/1.png	1
243	68	/media/68/0.jpg	0
244	68	/media/68/1.jpg	1
245	68	/media/68/2.png	2
246	69	/media/69/0.jpg	0
247	69	/media/69/1.png	1
248	70	/media/70/0.jpg	0
249	70	/media/70/1.png	1
250	71	/media/71/0.jpg	0
251	71	/media/71/1.jpg	1
252	71	/media/71/2.png	2
253	72	/media/72/0.png	0
254	72	/media/72/1.jpg	1
255	72	/media/72/2.png	2
256	73	/media/73/0.jpg	0
257	73	/media/73/1.jpg	1
258	73	/media/73/2.png	2
259	74	/media/74/0.jpg	0
260	74	/media/74/1.png	1
261	75	/media/75/0.jpg	0
262	75	/media/75/1.jpg	1
263	75	/media/75/2.jpg	2
264	75	/media/75/3.png	3
265	76	/media/76/0.jpg	0
266	76	/media/76/1.png	1
267	77	/media/77/0.jpg	0
268	77	/media/77/1.png	1
269	78	/media/78/0.jpg	0
270	78	/media/78/1.png	1
271	79	/media/79/0.jpg	0
272	79	/media/79/1.jpg	1
273	79	/media/79/2.png	2
275	80	/media/80/1.png	1
276	81	/media/81/0.jpg	0
277	81	/media/81/1.png	1
278	81	/media/81/2.jpg	2
279	81	/media/81/3.jpg	3
280	81	/media/81/4.jpg	4
281	81	/media/81/5.jpg	5
282	82	/media/82/0.jpg	0
283	82	/media/82/1.png	1
284	83	/media/83/0.png	0
285	83	/media/83/1.png	1
286	84	/media/84/0.jpg	0
287	84	/media/84/1.jpg	1
288	84	/media/84/2.png	2
289	85	/media/85/0.png	0
290	85	/media/85/1.png	1
291	86	/media/86/0.png	0
292	86	/media/86/1.png	1
293	87	/media/87/0.png	0
294	87	/media/87/1.png	1
295	88	/media/88/0.jpg	0
296	88	/media/88/1.jpg	1
297	88	/media/88/2.png	2
298	89	/media/89/0.jpg	0
299	89	/media/89/1.jpg	1
300	89	/media/89/2.png	2
301	90	/media/90/0.jpg	0
302	90	/media/90/1.jpg	1
303	90	/media/90/2.png	2
304	91	/media/91/0.jpg	0
305	91	/media/91/1.png	1
306	92	/media/92/0.jpg	0
307	92	/media/92/1.png	1
308	93	/media/93/0.jpg	0
309	93	/media/93/1.jpg	1
310	93	/media/93/2.png	2
311	94	/media/94/0.jpg	0
312	94	/media/94/1.png	1
313	95	/media/95/0.jpg	0
314	95	/media/95/1.jpg	1
315	95	/media/95/2.png	2
316	96	/media/96/0.png	0
317	96	/media/96/1.png	1
318	97	/media/97/0.png	0
319	97	/media/97/1.png	1
320	98	/media/98/0.png	0
321	98	/media/98/1.png	1
322	99	/media/99/0.jpg	0
323	99	/media/99/1.png	1
324	100	/media/100/0.png	0
325	100	/media/100/1.png	1
326	101	/media/101/0.png	0
327	101	/media/101/1.png	1
328	102	/media/102/0.jpg	0
329	102	/media/102/1.jpg	1
330	102	/media/102/2.jpg	2
331	102	/media/102/3.jpg	3
332	102	/media/102/4.png	4
333	103	/media/103/0.png	0
334	103	/media/103/1.jpg	1
335	103	/media/103/2.png	2
336	104	/media/104/0.jpg	0
337	104	/media/104/1.png	1
338	105	/media/105/0.jpg	0
339	105	/media/105/1.jpg	1
340	105	/media/105/2.jpg	2
341	105	/media/105/3.png	3
342	106	/media/106/0.jpg	0
343	106	/media/106/1.png	1
344	107	/media/107/0.jpg	0
345	107	/media/107/1.png	1
347	108	/media/108/1.png	1
348	109	/media/109/0.jpg	0
349	109	/media/109/1.jpg	1
350	109	/media/109/2.jpg	2
351	109	/media/109/3.jpg	3
352	109	/media/109/4.jpg	4
353	109	/media/109/5.png	5
354	110	/media/110/0.jpg	0
355	110	/media/110/1.png	1
356	111	/media/111/0.png	0
357	111	/media/111/1.jpg	1
358	111	/media/111/2.png	2
359	112	/media/112/0.jpg	0
360	112	/media/112/1.jpg	1
361	112	/media/112/2.jpg	2
362	112	/media/112/3.jpg	3
363	112	/media/112/4.jpg	4
364	112	/media/112/5.jpg	5
365	113	/media/113/0.jpg	0
366	113	/media/113/1.jpg	1
367	113	/media/113/2.jpg	2
368	113	/media/113/3.jpg	3
369	113	/media/113/4.jpg	4
370	113	/media/113/5.jpg	5
371	114	/media/114/0.jpg	0
372	114	/media/114/1.jpg	1
373	114	/media/114/2.jpg	2
374	114	/media/114/3.jpg	3
375	114	/media/114/4.jpg	4
376	114	/media/114/5.jpg	5
377	115	/media/115/0.jpg	0
378	115	/media/115/1.jpg	1
379	115	/media/115/2.jpg	2
380	115	/media/115/3.jpg	3
381	115	/media/115/4.jpg	4
382	115	/media/115/5.png	5
383	116	/media/116/0.jpg	0
384	116	/media/116/1.jpg	1
385	116	/media/116/2.jpg	2
386	116	/media/116/3.jpg	3
387	116	/media/116/4.jpg	4
388	116	/media/116/5.jpg	5
389	117	/media/117/0.png	0
390	117	/media/117/1.jpg	1
391	117	/media/117/2.jpg	2
392	117	/media/117/3.jpg	3
393	117	/media/117/4.png	4
394	118	/media/118/0.png	0
395	118	/media/118/1.png	1
396	119	/media/119/0.jpg	0
397	119	/media/119/1.jpg	1
398	119	/media/119/2.png	2
399	120	/media/120/0.png	0
400	120	/media/120/1.png	1
401	121	/media/121/0.jpg	0
402	121	/media/121/1.jpg	1
403	121	/media/121/2.png	2
404	122	/media/122/0.png	0
405	122	/media/122/1.jpg	1
406	122	/media/122/2.jpg	2
407	122	/media/122/3.png	3
408	123	/media/123/0.png	0
409	123	/media/123/1.png	1
410	124	/media/124/0.png	0
411	124	/media/124/1.png	1
412	125	/media/125/0.png	0
413	125	/media/125/1.png	1
414	126	/media/126/0.png	0
415	126	/media/126/1.jpg	1
416	126	/media/126/2.png	2
417	127	/media/127/0.png	0
418	127	/media/127/1.jpg	1
419	127	/media/127/2.png	2
420	128	/media/128/0.png	0
421	128	/media/128/1.png	1
422	129	/media/129/0.png	0
423	129	/media/129/1.png	1
424	130	/media/130/0.png	0
425	130	/media/130/1.png	1
426	131	/media/131/0.png	0
427	131	/media/131/1.jpg	1
428	131	/media/131/2.png	2
429	132	/media/132/0.jpg	0
430	132	/media/132/1.jpg	1
431	132	/media/132/2.png	2
432	133	/media/133/0.png	0
433	133	/media/133/1.png	1
434	134	/media/134/0.png	0
435	134	/media/134/1.png	1
436	135	/media/135/0.png	0
437	135	/media/135/1.png	1
438	136	/media/136/0.png	0
439	136	/media/136/1.png	1
440	137	/media/137/0.png	0
441	137	/media/137/1.png	1
442	138	/media/138/0.png	0
443	138	/media/138/1.png	1
444	139	/media/139/0.png	0
445	139	/media/139/1.png	1
446	140	/media/140/0.png	0
447	140	/media/140/1.png	1
448	141	/media/141/0.png	0
449	141	/media/141/1.png	1
450	142	/media/142/0.png	0
451	142	/media/142/1.png	1
452	143	/media/143/0.png	0
453	143	/media/143/1.png	1
454	144	/media/144/0.png	0
455	144	/media/144/1.png	1
456	145	/media/145/0.png	0
457	145	/media/145/1.png	1
458	146	/media/146/0.png	0
459	146	/media/146/1.png	1
460	147	/media/147/0.png	0
461	147	/media/147/1.png	1
462	148	/media/148/0.png	0
463	148	/media/148/1.png	1
464	149	/media/149/0.jpg	0
465	149	/media/149/1.png	1
466	150	/media/150/0.jpg	0
467	150	/media/150/1.png	1
468	151	/media/151/0.png	0
469	151	/media/151/1.png	1
470	152	/media/152/0.png	0
471	152	/media/152/1.png	1
472	153	/media/153/0.png	0
473	153	/media/153/1.png	1
474	154	/media/154/0.png	0
475	154	/media/154/1.jpg	1
476	154	/media/154/2.jpg	2
477	154	/media/154/3.jpg	3
478	154	/media/154/4.png	4
479	155	/media/155/0.png	0
480	155	/media/155/1.jpg	1
481	155	/media/155/2.png	2
482	156	/media/156/0.jpg	0
483	156	/media/156/1.jpg	1
484	156	/media/156/2.jpg	2
485	156	/media/156/3.jpg	3
486	156	/media/156/4.jpg	4
487	156	/media/156/5.png	5
488	157	/media/157/0.png	0
489	157	/media/157/1.png	1
490	158	/media/158/0.png	0
491	158	/media/158/1.png	1
492	159	/media/159/0.jpg	0
493	159	/media/159/1.jpg	1
494	159	/media/159/2.png	2
495	160	/media/160/0.jpg	0
496	160	/media/160/1.jpg	1
497	160	/media/160/2.jpg	2
498	160	/media/160/3.jpg	3
499	160	/media/160/4.jpg	4
500	160	/media/160/5.png	5
501	161	/media/161/0.png	0
502	161	/media/161/1.png	1
503	162	/media/162/0.jpg	0
504	162	/media/162/1.png	1
505	163	/media/163/0.png	0
506	163	/media/163/1.jpg	1
507	163	/media/163/2.jpg	2
508	163	/media/163/3.png	3
509	164	/media/164/0.jpg	0
510	164	/media/164/1.jpg	1
511	164	/media/164/2.png	2
512	165	/media/165/0.jpg	0
513	165	/media/165/1.jpg	1
514	165	/media/165/2.jpg	2
515	165	/media/165/3.png	3
516	166	/media/166/0.jpg	0
517	166	/media/166/1.png	1
518	167	/media/167/0.jpg	0
519	167	/media/167/1.png	1
520	168	/media/168/0.png	0
521	168	/media/168/1.png	1
522	169	/media/169/0.png	0
523	169	/media/169/1.png	1
524	170	/media/170/0.png	0
525	170	/media/170/1.jpg	1
526	170	/media/170/2.png	2
527	171	/media/171/0.png	0
528	171	/media/171/1.jpg	1
529	171	/media/171/2.png	2
530	172	/media/172/0.png	0
531	172	/media/172/1.jpg	1
532	172	/media/172/2.png	2
533	173	/media/173/0.png	0
534	173	/media/173/1.png	1
535	174	/media/174/0.jpg	0
536	174	/media/174/1.png	1
537	175	/media/175/0.jpg	0
538	175	/media/175/1.png	1
539	176	/media/176/0.jpg	0
540	176	/media/176/1.jpg	1
541	176	/media/176/2.png	2
542	177	/media/177/0.jpg	0
543	177	/media/177/1.png	1
544	178	/media/178/0.jpg	0
545	178	/media/178/1.png	1
546	179	/media/179/0.png	0
547	179	/media/179/1.jpg	1
548	179	/media/179/2.jpg	2
549	179	/media/179/3.jpg	3
550	179	/media/179/4.png	4
551	180	/media/180/0.png	0
552	180	/media/180/1.png	1
553	181	/media/181/0.jpg	0
554	181	/media/181/1.png	1
555	182	/media/182/0.jpg	0
556	182	/media/182/1.jpg	1
557	182	/media/182/2.png	2
558	183	/media/183/0.png	0
559	183	/media/183/1.png	1
561	184	/media/184/1.png	1
562	185	/media/185/0.png	0
563	185	/media/185/1.png	1
564	186	/media/186/0.png	0
565	186	/media/186/1.png	1
566	187	/media/187/0.png	0
567	187	/media/187/1.png	1
568	188	/media/188/0.png	0
569	188	/media/188/1.png	1
570	189	/media/189/0.png	0
571	189	/media/189/1.png	1
572	190	/media/190/0.jpg	0
573	190	/media/190/1.jpg	1
574	190	/media/190/2.jpg	2
575	190	/media/190/3.png	3
576	191	/media/191/0.jpg	0
577	191	/media/191/1.png	1
578	192	/media/192/0.jpg	0
579	192	/media/192/1.png	1
580	193	/media/193/0.png	0
581	193	/media/193/1.png	1
582	194	/media/194/0.jpg	0
583	194	/media/194/1.png	1
584	195	/media/195/0.png	0
585	195	/media/195/1.png	1
586	196	/media/196/0.jpg	0
587	196	/media/196/1.png	1
588	197	/media/197/0.png	0
589	197	/media/197/1.png	1
590	198	/media/198/0.png	0
591	198	/media/198/1.png	1
592	199	/media/199/0.jpg	0
593	199	/media/199/1.png	1
594	200	/media/200/0.jpg	0
595	200	/media/200/1.jpg	1
596	200	/media/200/2.png	2
597	201	/media/201/0.png	0
598	201	/media/201/1.png	1
599	202	/media/202/0.jpg	0
600	202	/media/202/1.jpg	1
601	202	/media/202/2.jpg	2
602	202	/media/202/3.jpg	3
603	202	/media/202/4.jpg	4
604	202	/media/202/5.png	5
605	203	/media/203/0.jpg	0
606	203	/media/203/1.jpg	1
607	203	/media/203/2.jpg	2
608	203	/media/203/3.jpg	3
609	203	/media/203/4.jpg	4
610	203	/media/203/5.png	5
611	204	/media/204/0.jpg	0
612	204	/media/204/1.jpg	1
613	204	/media/204/2.jpg	2
614	204	/media/204/3.jpg	3
615	204	/media/204/4.jpg	4
616	204	/media/204/5.png	5
617	205	/media/205/0.png	0
618	205	/media/205/1.jpg	1
619	205	/media/205/2.png	2
620	206	/media/206/0.png	0
621	206	/media/206/1.jpg	1
622	206	/media/206/2.png	2
623	207	/media/207/0.jpg	0
624	207	/media/207/1.jpg	1
625	207	/media/207/2.png	2
626	208	/media/208/0.jpg	0
627	208	/media/208/1.jpg	1
628	208	/media/208/2.png	2
629	209	/media/209/0.png	0
630	209	/media/209/1.png	1
631	210	/media/210/0.jpg	0
632	210	/media/210/1.jpg	1
633	210	/media/210/2.jpg	2
634	210	/media/210/3.png	3
635	211	/media/211/0.jpg	0
636	211	/media/211/1.jpg	1
637	211	/media/211/2.png	2
638	212	/media/212/0.png	0
639	212	/media/212/1.jpg	1
640	212	/media/212/2.jpg	2
641	212	/media/212/3.jpg	3
642	212	/media/212/4.png	4
643	213	/media/213/0.png	0
644	213	/media/213/1.jpg	1
645	213	/media/213/2.png	2
646	214	/media/214/0.jpg	0
647	214	/media/214/1.jpg	1
648	214	/media/214/2.jpg	2
649	214	/media/214/3.jpg	3
650	214	/media/214/4.jpg	4
651	214	/media/214/5.png	5
652	215	/media/215/0.jpg	0
653	215	/media/215/1.jpg	1
654	215	/media/215/2.jpg	2
655	215	/media/215/3.jpg	3
656	215	/media/215/4.jpg	4
657	215	/media/215/5.png	5
658	216	/media/216/0.jpg	0
659	216	/media/216/1.jpg	1
660	216	/media/216/2.jpg	2
661	216	/media/216/3.jpg	3
662	216	/media/216/4.jpg	4
663	216	/media/216/5.png	5
664	217	/media/217/0.jpg	0
665	217	/media/217/1.jpg	1
666	217	/media/217/2.jpg	2
667	217	/media/217/3.jpg	3
668	217	/media/217/4.jpg	4
669	217	/media/217/5.png	5
670	218	/media/218/0.jpg	0
671	218	/media/218/1.jpg	1
672	218	/media/218/2.jpg	2
673	218	/media/218/3.jpg	3
674	218	/media/218/4.jpg	4
675	218	/media/218/5.png	5
676	219	/media/219/0.jpg	0
677	219	/media/219/1.jpg	1
678	219	/media/219/2.jpg	2
679	219	/media/219/3.png	3
680	219	/media/219/4.png	4
681	220	/media/220/0.jpg	0
682	220	/media/220/1.png	1
683	221	/media/221/0.png	0
684	221	/media/221/1.jpg	1
685	221	/media/221/2.png	2
686	222	/media/222/0.jpg	0
687	222	/media/222/1.jpg	1
688	222	/media/222/2.jpg	2
689	222	/media/222/3.jpg	3
690	222	/media/222/4.png	4
691	223	/media/223/0.jpg	0
692	223	/media/223/1.jpg	1
693	223	/media/223/2.jpg	2
694	223	/media/223/3.jpg	3
695	223	/media/223/4.jpg	4
696	223	/media/223/5.png	5
697	224	/media/224/0.jpg	0
698	224	/media/224/1.jpg	1
699	224	/media/224/2.jpg	2
700	224	/media/224/3.jpg	3
701	224	/media/224/4.jpg	4
703	225	/media/225/0.jpg	0
704	225	/media/225/1.jpg	1
705	225	/media/225/2.jpg	2
706	225	/media/225/3.jpg	3
707	225	/media/225/4.jpg	4
708	225	/media/225/5.png	5
709	226	/media/226/0.png	0
710	226	/media/226/1.png	1
711	227	/media/227/0.png	0
712	227	/media/227/1.png	1
713	228	/media/228/0.png	0
714	228	/media/228/1.jpg	1
715	228	/media/228/2.jpg	2
716	228	/media/228/3.png	3
717	229	/media/229/0.jpg	0
718	229	/media/229/1.png	1
719	230	/media/230/0.jpg	0
720	230	/media/230/1.png	1
721	231	/media/231/0.jpg	0
722	231	/media/231/1.jpg	1
723	231	/media/231/2.png	2
724	232	/media/232/0.jpg	0
725	232	/media/232/1.jpg	1
726	232	/media/232/2.png	2
727	233	/media/233/0.jpg	0
728	233	/media/233/1.png	1
729	234	/media/234/0.jpg	0
730	234	/media/234/1.jpg	1
731	234	/media/234/2.png	2
732	235	/media/235/0.jpg	0
733	235	/media/235/1.png	1
734	236	/media/236/0.jpg	0
735	236	/media/236/1.png	1
736	237	/media/237/0.png	0
737	237	/media/237/1.jpg	1
738	237	/media/237/2.jpg	2
739	237	/media/237/3.jpg	3
740	237	/media/237/4.png	4
741	238	/media/238/0.jpg	0
742	238	/media/238/1.jpg	1
743	238	/media/238/2.jpg	2
744	238	/media/238/3.png	3
745	239	/media/239/0.jpg	0
746	239	/media/239/1.jpg	1
747	239	/media/239/2.png	2
748	239	/media/239/3.png	3
749	240	/media/240/0.png	0
750	240	/media/240/1.jpg	1
751	240	/media/240/2.jpg	2
752	240	/media/240/3.jpg	3
753	240	/media/240/4.jpg	4
754	240	/media/240/5.png	5
755	241	/media/241/0.png	0
756	241	/media/241/1.jpg	1
757	241	/media/241/2.png	2
758	242	/media/242/0.png	0
759	242	/media/242/1.jpg	1
760	242	/media/242/2.png	2
761	243	/media/243/0.jpg	0
762	243	/media/243/1.png	1
763	244	/media/244/0.jpg	0
764	244	/media/244/1.png	1
765	245	/media/245/0.jpg	0
766	245	/media/245/1.png	1
767	246	/media/246/0.jpg	0
768	246	/media/246/1.png	1
769	247	/media/247/0.jpg	0
770	247	/media/247/1.png	1
771	248	/media/248/0.png	0
772	248	/media/248/1.png	1
8	2	/media/2/2.jpg	2
66	16	/media/16/0.jpg	0
135	33	/media/33/2.png	2
203	52	/media/52/1.png	1
274	80	/media/80/0.png	0
346	108	/media/108/0.jpg	0
560	184	/media/184/0.png	0
702	224	/media/224/5.png	5
773	249	/media/249/0.png	0
774	249	/media/249/1.png	1
775	250	/media/250/0.png	0
776	250	/media/250/1.png	1
777	251	/media/251/0.png	0
778	251	/media/251/1.png	1
779	252	/media/252/0.png	0
780	252	/media/252/1.png	1
781	253	/media/253/0.png	0
782	253	/media/253/1.png	1
783	254	/media/254/0.png	0
784	254	/media/254/1.png	1
785	255	/media/255/0.png	0
786	255	/media/255/1.png	1
787	256	/media/256/0.jpg	0
788	256	/media/256/1.jpg	1
789	256	/media/256/2.jpg	2
790	256	/media/256/3.png	3
791	257	/media/257/0.jpg	0
792	257	/media/257/1.png	1
793	258	/media/258/0.png	0
794	258	/media/258/1.png	1
795	259	/media/259/0.png	0
796	259	/media/259/1.png	1
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, slug, title, reference, brand, price_cents, currency, short_desc, long_desc, features, stock_status, source_url, created_at, updated_at) FROM stdin;
2	antivol-remorque-pour-tete-dattelage-avec-le-cadenas	Antivol remorque pour tête d’attelage (avec le cadenas) – Planetline	0410251	\N	4050	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/antivol-remorque-pour-tete-dattelage-avec-le-cadenas/	2026-07-06 16:41:36.123769+02	2026-07-07 02:23:45.588952+02
3	bache-de-pare-brise-sous-tube-180-x-080m	Bâche de pare-brise sous tube 1,80 x 0,80m – Impex	IMX	\N	705	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/bache-de-pare-brise-sous-tube-180-x-080m/	2026-07-06 16:41:36.132672+02	2026-07-07 02:23:49.766405+02
5	bidon-adblue	Bidon AdBlue avec bec verseur 10L – Diframa	DIFADBL010BV	\N	1690	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/bidon-adblue/	2026-07-06 16:41:36.150899+02	2026-07-07 02:24:46.909992+02
6	boite-de-fusibles-accessoires-28-pieces	Boîte de fusibles + Accessoires 28 pièces – Sumex	SUMFUS0028	\N	480	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/boite-de-fusibles-accessoires-28-pieces/	2026-07-06 16:41:36.16038+02	2026-07-07 02:24:51.036472+02
7	booster-12v-1500a-avec-power-bank-10000mah-schumacher	Booster 12V 1500A avec power bank 10000mAh – Schumacher	SOD54086	\N	20000	EUR	Booster : indispensable pour démarrer votre véhicule en toutes circonstances et recharger vos appareils électroniques où que vous soyez.	Description\nDécouvrez le booster de démarrage 12V 1500A équipé d’une power bank intégrée de 10000mAh, l’outil indispensable pour démarrer votre véhicule en toutes circonstances et recharger vos appareils électroniques où que vous soyez.\nCaractéristiques :\nLongueur du câble – 0,45m\nAlimentation – USB-C\nAmpérage – 2,4 – 3A\nCapacité batterie – 10000mAh\nTension de démarrage – 12V\nCourant de démarrage en crête – 1500A\nCourant de démarrage – 750A\nDimensions – 245x130x115mm\nDigital – oui\nPoids article – 2,4KG	[]	en_stock	https://pieces-auto.fr/shop/booster-12v-1500a-avec-power-bank-10000mah-schumacher/	2026-07-06 16:41:36.169027+02	2026-07-07 02:24:55.263464+02
8	booster-12v-600a-avec-power-bank-6500mah-schumacher	Booster 12V 600A avec power bank 6500mAh – Schumacher	SOD54083	\N	15000	EUR	Booster voiture : indispensable pour démarrer votre véhicule en toutes circonstances et recharger vos appareils électroniques où que vous soyez.	Description\nCaractéristiques :\nLongueur du câble – 0,45m\nAlimentation – USB-C\nAmpérage – 2,4A\nCapacité batterie – 6500mAh\nTension de démarrage – 12V\nCourant de démarrage en crête – 600A\nCourant de démarrage – 300A\nType – Lithium Li-on\nDimensions – 202x112x73mm\nDigital – oui\nPoids article  0,76KG	[]	en_stock	https://pieces-auto.fr/shop/booster-12v-600a-avec-power-bank-6500mah-schumacher/	2026-07-06 16:41:36.179618+02	2026-07-07 02:24:59.108395+02
10	cables-de-demarrage-en-cca-25mm²-2x30m-480a-pinces-isolees	Câbles de démarrage en CCA 25mm² 2×3,0m 480A pinces isolées – Sodise	SOD54362	\N	2650	EUR	Ces câbles de démarrage en CCA sont conçus pour garantir un démarrage rapide et fiable de votre véhicule, même dans les conditions les plus exigeantes	Description\nCaractéristiques principales :\n– Section 25mm² : assure une conductivité supérieure pour un transfert de courant renforcé.\n– Longueur totale 2×3,0m : suffisamment longs pour connecter facilement deux véhicules, même dans des espaces restreints.\n– Courant nominal 480A : adapté aux véhicules lourds, utilitaires et pour des situations nécessitant une puissance plus élevée.\n– Pinces isolées robustes : garantissent une utilisation sécurisée en évitant tout contact accidentel avec des parties métalliques.\n– Matériaux CCA (Copper-Clad Aluminium) : combine la conductivité efficace du cuivre avec la légèreté de l’aluminium pour un produit durable et maniable.\n– Souplesse et durabilité : câbles flexibles conçus pour résister à l’usure et aux conditions extérieures difficiles.	[]	en_stock	https://pieces-auto.fr/shop/cables-de-demarrage-en-cca-25mm%c2%b2-2x30m-480a-pinces-isolees/	2026-07-06 16:41:36.207188+02	2026-07-07 02:25:07.203824+02
40	nettoyant-jantes-gel-titanium-800-ml	Nettoyant Jantes Gel Titanium 800ml – GS27	CL120137	\N	2000	EUR	Avec sa formule unique et très résistante utilisée dans des secteurs de pointe comme l’aéronautique et la Formule 1, le Nettoyant Jantes Gel Titanium® GS27 Classics® format 800ml adhère totalement à la jante & enjoliveur pour assurer un nettoyage et un entretien complet. Ce nettoyant jantes est un l’idéal … En savoir plus	Description\nAvec sa\nformule unique\net\ntrès résistante\nutilisée dans des secteurs de pointe comme l’aéronautique et la Formule 1, le\nNettoyant Jantes Gel Titanium\n®\nGS27 Classics® format 800ml\nadhère totalement à la jante & enjoliveur pour assurer un\nnettoyage et un entretien complet\n.\nCe\nnettoyant jantes est un l’idéal dans sa catégorie\n. Il nettoie les poussières de frein, les graisses incrustées et autres saletés. Sa\nformule brevetée\nlaisse un\nfilm protecteur\nsur vos jantes ou enjoliveur qui\nretarder le ré encrassement\net\nlui procurer une brillance intense\n.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-jantes-gel-titanium-800-ml/	2026-07-06 16:41:36.570111+02	2026-07-07 02:27:08.305191+02
12	chaine-neige-husky-advance-9mm-sum	Chaîne neige husky advance 9mm – Sumex	N/A	\N	4399	EUR	Les chaînes à neige Husky Advance sont l'accessoire idéal pour ceux qui recherchent des chaînes à neige faciles à monter sur les roues de leur véhicule.	Description\nConduisez en toute sécurité sur les routes enneigées grâce aux chaînes à neige Husky Classic.\nCes chaînes sont fabriquées en acier de haute qualité, d’une épaisseur de 9 mm et de diamètre 3,5 mm, bien plus grand que les chaînes ordinaires, ce qui assure une position stable et optimale de la chaîne pendant la conduite. Le motif en forme de D des anneaux offre une meilleure adhérence que les chaînes courantes sur le marché avec une installation rapide et facile sans avoir à soulever la roue.\nLes chaînes à neige Husky Classic sont parfaitement adaptées aux systèmes de freinage ABS.\nElles sont idéales pour les petits coffres où l’espace entre le pneu et la roue de secours est limité.\nElles sont présentées dans un petit boîtier robuste en plastique ABS contenant 2 chaînes pour les roues motrices, une brochure avec des instructions et des gants pour les monter.\nLes chaînes à neige Husky Classic sont certifiées : EN16662-1-2020, ONORM V5117 : 2007.\nPour connaître la taille des chaînes dont votre voiture a besoin, nous vous recommandons de consulter les mesures de votre pneu (par exemple 195/55 R16).	[]	en_stock	https://pieces-auto.fr/shop/chaine-neige-husky-advance-9mm-sum/	2026-07-06 16:41:36.23239+02	2026-07-07 02:25:15.63026+02
13	chargeur-electronique-automatique-6-12v-4a-stilker	Chargeur électronique automatique 6/12V 4A 60W – Stilker	\N	\N	9570	EUR	Optimisez la recharge de vos batteries avec ce chargeur : compatible 6V et 12V, puissance de 60W et courant de 4A pour une charge rapide et efficace	Description\nChargeur électronique automatique 6/12V 4A 60W Stilker – Optimisez la recharge de vos batteries avec ce chargeur automatique, compatible 6V et 12V, délivrant une puissance de 60W et un courant de 4A pour une charge rapide, sûre et efficace.\nLes plus :\n➟ Maintien de charge\n➟ Indicateur lumineux (rouge : en charge – vert : batterie chargée)\nDécouvrez tous les produits de la marque\nStilker	[]	en_stock	https://pieces-auto.fr/shop/chargeur-electronique-automatique-6-12v-4a-stilker/	2026-07-06 16:41:36.241928+02	2026-07-07 02:25:19.828736+02
14	chargeur-sodistart-6-12v	Chargeur Sodistart 6- 12V – Stilker	SOD04021	\N	2900	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chargeur-sodistart-6-12v/	2026-07-06 16:41:36.250179+02	2026-07-07 02:25:23.664999+02
15	chaussette-neige-taille-l-sumex	Chaussettes de neige Taille L – Sumex	SUMHUSTX03	\N	5290	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chaussette-neige-taille-l-sumex/	2026-07-06 16:41:36.257131+02	2026-07-07 02:25:27.793763+02
16	chaussette-neige-taille-m-sumex	Chaussettes de neige Taille M – Sumex	SUMHUSTX02	\N	5290	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chaussette-neige-taille-m-sumex/	2026-07-06 16:41:36.265099+02	2026-07-07 02:25:31.643313+02
17	chaussette-neige-taille-xxl-sumex	Chaussettes de neige Taille XXL – Sumex	SUMHUSTX05	\N	5690	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chaussette-neige-taille-xxl-sumex/	2026-07-06 16:41:36.273642+02	2026-07-07 02:25:35.839116+02
18	chaussettes-de-neige-taille-xl-sumex	Chaussettes de neige Taille XL – Sumex	SUMHUSTX04	\N	5690	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chaussettes-de-neige-taille-xl-sumex/	2026-07-06 16:41:36.280653+02	2026-07-07 02:25:39.917089+02
19	chaussettes-neige-taille-s-sumex	Chaussettes de neige Taille S – Sumex	SUMHUSTX01	\N	5190	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/chaussettes-neige-taille-s-sumex/	2026-07-06 16:41:36.2884+02	2026-07-07 02:25:44.099105+02
20	cle-dynamometrique-1-2-28-a-210nm-drakkar	Clé dynamométrique 1/2″ 28 à 210Nm – Drakkar	SOD15226	\N	7500	EUR	Clé dynamométrique réversible 1/2" (28 à 210 Nm) avec blocage par molette, cliquet robuste, et livrée en coffret PVC. Livrée avec 2 rallonges de 120 mm et 30 mm pour plus de polyvalence.	Description\nCette clé dynamométrique réversible 1/2″ offre un serrage précis et fiable de 28 à 210 Nm, idéale pour vos travaux mécaniques et industriels. Son mécanisme de blocage par molette garantit un réglage stable du couple, évitant tout décalage accidentel pendant l’utilisation.\nLe cliquet robuste facilite les opérations dans les espaces confinés, tandis que la fonction réversible augmente la flexibilité d’usage, simplifiant le vissage et le dévissage.\nPour encore plus de polyvalence, cette clé est fournie avec deux rallonges pratiques de 120 mm et 30 mm, vous permettant d’atteindre facilement les endroits difficiles d’accès.\nLe tout est présenté dans un coffret PVC solide qui protège l’outil contre les chocs et facilite son rangement et son transport. Une solution complète pour un serrage précis et efficace.	[]	en_stock	https://pieces-auto.fr/shop/cle-dynamometrique-1-2-28-a-210nm-drakkar/	2026-07-06 16:41:36.296702+02	2026-07-07 02:25:47.888662+02
21	cric-losange-a-manivelle-1t	Cric losange manuel à manivelle capacité 1T – Stilker	SOD15305	\N	1550	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/cric-losange-a-manivelle-1t/	2026-07-06 16:41:36.304267+02	2026-07-07 02:25:52.022752+02
22	cric-rouleur-2t	Cric rouleur hydraulique capacité 2T – Stilker	SOD15452	\N	4900	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/cric-rouleur-2t/	2026-07-06 16:41:36.311481+02	2026-07-07 02:25:55.875855+02
41	nettoyant-plastique-protection-pulverisateur	Nettoyant plastique protection + pulvérisateur – GS27	CL120241	\N	1050	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-plastique-protection-pulverisateur/	2026-07-06 16:41:36.577922+02	2026-07-07 02:27:12.168995+02
42	prise-dattelage-femelle-13-broches	Prise d’attelage femelle 13 broches – Restagraf	17434	\N	1450	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/prise-dattelage-femelle-13-broches/	2026-07-06 16:41:36.584811+02	2026-07-07 02:27:16.513338+02
43	prise-dattelage-femelle-7-broches	Prise d’attelage femelle 7 broches – Restagraf	17432	\N	1450	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/prise-dattelage-femelle-7-broches/	2026-07-06 16:41:36.592748+02	2026-07-07 02:27:20.683218+02
44	prise-dattelage-male-13-broches	Prise d’attelage mâle 13 broches – Restagraf	17435	\N	1350	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/prise-dattelage-male-13-broches/	2026-07-06 16:41:36.599997+02	2026-07-07 02:27:25.134547+02
24	decrassant-5-en-1-moteur-essence-bardahl-1-l-300-ml-offerts	Décrassant 5 En 1 Moteur Essence 1 L + 300ml Offerts – Bardahl	SAD9396	\N	6090	EUR	Le Décrassant moteur 5 en 1 de Bardahl permet de nettoyer votre moteur en ciblant précisément les organes les plus sensibles à l'encrassement. Sa formule se base sur un complexe d'additifs multifonctionnels issus de nos dernières recherches.  Les substances hautement concentrées qu’il contient utilisent votre carburant comme transporteur afin de nettoyer au mieux votre moteur. Il suffit donc de verser le Décrassant moteur 5 en 1 dans votre réservoir, et c’est votre carburant additivé qui sert de solution curative.	Description\nLe Décrassant moteur 5 en 1 (essence) est le fruit de nos dernières recherches. Sa composition aux multiples propriétés lui permet d’agir sur chaque organe du moteur de manière efficace et sans danger.\nSimple et rapide d’utilisation.\nDécrasse sans démontage\n:\nle turbo, la vanne EGR, le filtre à particules, les soupapes d’échappement et le pot catalytique.\nNettoie et protège le système d’injection, et rétablit le débit des injecteurs.\nLimite les émissions polluantes et multiplie vos chances de réussite aux tests antipollution du contrôle technique.\nÉvite la surconsommation de carburant, la perte de puissance et le remplacement de pièces coûteuses.\nCompatible avec tous les véhicules hybrides	[]	en_stock	https://pieces-auto.fr/shop/decrassant-5-en-1-moteur-essence-bardahl-1-l-300-ml-offerts/	2026-07-06 16:41:36.325366+02	2026-07-07 02:26:03.794255+02
25	coffret-de-46-pcs-douilles-1-4	Douilles 1/4″ – Coffret de 46 pièces – Stilker	SOD67509	\N	2200	EUR	Composition : – 13 douilles 1/4″ : 4-4,5-5-5,5-6-7-8-9-10-11-12-13-14mm – 1 rallonge coulissante 115mm – 1 rallonge flexible 150mm – 2 rallonges 50mm et 100mm – 1 adaptateur hex 30mm – 1 barre coulissante 115mm – 1 cardan 1/4″ – 1 … En savoir plus	Description\nComposition :\n– 13 douilles 1/4″ : 4-4,5-5-5,5-6-7-8-9-10-11-12-13-14mm\n– 1 rallonge coulissante 115mm\n– 1 rallonge flexible 150mm\n– 2 rallonges 50mm et 100mm\n– 1 adaptateur hex 30mm\n– 1 barre coulissante 115mm\n– 1 cardan 1/4″\n– 1 cliquet réversible 1/4″ 45 dents\n– 4 clés mâles 1,27-1,5-2-2,5\n– 21 embouts : TX : 10-15-20-25-30-40 Hex : 3-4-5-6-7-8 PH : 1-2-3 PZ : 1-2-3 FD : 4-5,5-7\nAcier chrome vanadium.	[]	en_stock	https://pieces-auto.fr/shop/coffret-de-46-pcs-douilles-1-4/	2026-07-06 16:41:36.335041+02	2026-07-07 02:26:07.92542+02
26	degivrant-pare-brise-600ml-holts	Dégivrant pare-brise -40°c 600ML – Holts	SGD52081710128	\N	1200	EUR	Dégivrant pare-brise Hots 600 ml, efficace pour enlever rapidement givre et glace, assurant une visibilité claire et sécurisée en hiver.	Description\nCe dégivrant pare-brise Hots 600 ml agit efficacement jusqu’à -40°C pour dégivrer rapidement toutes les surfaces vitrées.\nPulvérisation large pour une couverture optimale et une action rapide.\nNe laisse aucune trace ni résidu.\nLimite la réapparition du givre pour plus de confort.	[]	en_stock	https://pieces-auto.fr/shop/degivrant-pare-brise-600ml-holts/	2026-07-06 16:41:36.342382+02	2026-07-07 02:26:11.784536+02
27	demarrage-moteur-start-pilote-300ml	Démarrage moteur Start Pilote 300ML – Holts	HOLHSTA0001A	\N	1500	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/demarrage-moteur-start-pilote-300ml/	2026-07-06 16:41:36.348547+02	2026-07-07 02:26:16.177778+02
29	douilles-1-4-3-8-1-2-coffret-de-171-pieces-stilker	Douilles 1/4″ 3/8″ 1/2″ – Coffret de 171 pièces – Stilker	SOD67509-2	\N	7900	EUR	Composition : – 8 douilles longues 1/4″ : 6-7-8-9-10-11-12-13mm – 4 douilles longues 1/2″ : 14-15-17-19mm – 1 adaptateur 1/2″ pour embouts 8mm – 1 adaptateur pour douilles 1/4″ – 17 portes-embouts avec embout – 15 embouts 8mm – 13 … En savoir plus	Description\nComposition :\n– 8 douilles longues 1/4″ : 6-7-8-9-10-11-12-13mm\n– 4 douilles longues 1/2″ : 14-15-17-19mm\n– 1 adaptateur 1/2″ pour embouts 8mm\n– 1 adaptateur pour douilles 1/4″\n– 17 portes-embouts avec embout\n– 15 embouts 8mm\n– 13 douilles 1/4″ : 4-4,5-5-5,5-6-7-8-9-10-11-12-13-14mm\n– 18 douilles 1/2″ : 10-11-12-13-14-15-16-17-18-19-20-21-22-23-24-27-30-32mm\n– 1 cliquet 1/4″ réversible 45 dents\n– 1 cliquet 1/2″ réversible 45 dents\n– 1 rallonge coulissante 1/2″ 125mm\n– 1 douille à bougies 16\n– 1 douille à bougies 21\n– 1 cardan 1/4″\n– 1 cardan 1/2″\n– 1 barre coulissante 1/4″\n– 1 barre coulissante 1/2″\n– 1 tournevis porte-embouts 1/4″\n– 1 rallonge coulissante 1/4″ 100mm\n– 1 rallonge coulissante 1/4″ 50mm\n– 1 rallonge flexible 1/4″ 150mm\n– 3 clés hexagonales\nAcier chrome vanadium.	[]	en_stock	https://pieces-auto.fr/shop/douilles-1-4-3-8-1-2-coffret-de-171-pieces-stilker/	2026-07-06 16:41:36.366196+02	2026-07-07 02:26:24.311386+02
31	jerrican-plastique-10l-special-hydrocarbure	Jerrican Plastique 10L “Spécial Hydrocarbure” – Intfradis	INT537	\N	1700	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/jerrican-plastique-10l-special-hydrocarbure/	2026-07-06 16:41:36.399985+02	2026-07-07 02:26:32.359547+02
32	jerrican-plastique-20l-special-hydrocarbure	Jerrican Plastique 20L “Spécial Hydrocarbure” – Intfradis	INT538	\N	3240	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/jerrican-plastique-20l-special-hydrocarbure/	2026-07-06 16:41:36.408323+02	2026-07-07 02:26:36.427769+02
33	jerrican-plastique-5l-special-hydrocarbure	Jerrican Plastique 5L “Spécial Hydrocarbure” – Intfradis	INT536	\N	1330	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/jerrican-plastique-5l-special-hydrocarbure/	2026-07-06 16:41:36.437417+02	2026-07-07 02:26:40.546268+02
34	kit-gilet-triangle	Kit gilet haute visibilité + triangle homologué – Intfradis	INT491	\N	1800	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/kit-gilet-triangle/	2026-07-06 16:41:36.459138+02	2026-07-07 02:26:44.360453+02
35	kit-renovation-optiques-renovation-machine	Kit rénovation optiques – GS27	CL162000	\N	3200	EUR	Grâce au Kit Rénovation Optiques GS27® Classics, rénovez vous-même vos optiques.Facile, rapide, sans risque pour une protection et un résultat durable.	Description\nCe kit rénovation phare professionnel multi-usage est le\nmoyen le plus facile et efficace pour rénover l’ensemble de votre véhicule\n(auto ou moto) : lunettes arrière plastiques de cabriolet, jantes et enjoliveur, bulles de carénages de moto.\nCe Kit contient :\n– 1 tube de 100ml Rénovateur Optiques\n– 1 adaptateur pour perceuse tige 6mm\n– 1 mousse 80 x 25mm\n– 8 disques abrasifs 75 : 2 abrasifs P600, 2 abrasifs P1000, 2 abrasifs P2000, 2 abrasifs P3000\n– 1 ruban adhésif masquant 38mm x 10m\n– 1 sachet Lustreur Protecteur Titanium+ 20ml\n– 1 microfibre 40 x40cm\n– 1 notice d’utilisation\nDécouvrez nos autres produits\nGS7	[]	en_stock	https://pieces-auto.fr/shop/kit-renovation-optiques-renovation-machine/	2026-07-06 16:41:36.480884+02	2026-07-07 02:26:48.365275+02
36	kit-signalisation-arriere-led-wifi-4-fonctions	Kit signalisation arrière led wifi 4 fonctions – Stilker	SOD16142	\N	6690	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/kit-signalisation-arriere-led-wifi-4-fonctions/	2026-07-06 16:41:36.501346+02	2026-07-07 02:26:52.455886+02
37	lave-glace-hiver-5l	Lave-glace voiture Été / Hiver 5L – Friz	DIFLGSM005	\N	690	EUR	Ce lave-glace été-hiver 5L de Diframa peut être utilisé toute l'année. Nettoyage rapide et efficace du pare-brise. Commandez en ligne et payez en magasin.	Description\nPourquoi utiliser le lave-glace voiture, été hiver de Diframa ?\n– Directement prêt à l’emploi\n– Nettoyage rapide et efficace du pare-brise\n– Peut être utilisé sur tous types de véhicules\n– Élimination de la poussière, de la saleté et des tâches tenaces\n– Résistant jusqu’à -20°\n– Fonction dégraissante\n– Formule sans méthanol\n– Lave-glace voiture parfumé\n– Solution démoustiqueur et anti-givre\n– Contient moins de 5% d’agent de surface anionique\n– Fabrication française\n– Vapeurs et liquide inflammables\nDécouvrez nos produits\nEntretien & Nettoyage	[]	en_stock	https://pieces-auto.fr/shop/lave-glace-hiver-5l/	2026-07-06 16:41:36.522888+02	2026-07-07 02:26:56.265314+02
39	nettoyant-decontaminant-jantes-500ml	Nettoyant décontaminant jantes 500ml – GS27	CL120311	\N	1190	EUR	Grâce à sa formule pH neutre, le Nettoyant Décontaminant Jantes nettoie en profondeur les jantes, sans risque de les abîmer.  Il est efficace sur tous les types de jantes, même les plus sensibles (aluminium, mates, anodisées, carbone, magnésium, chromées...).  Il change de couleur au contact des particules ferreuses et les dissout complètement. Il est notamment très efficace sur les poussières de freins qui sont composées essentiellement de fer. Il neutralise le voile terne provoqué par la corrosion et redonne aux jantes leur aspect original.  Sa formule gel assure une meilleure adhérence du produit sur la jante.	Description\nDécouvrez nos autres produits\nGS27	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-decontaminant-jantes-500ml/	2026-07-06 16:41:36.560102+02	2026-07-07 02:27:04.202874+02
45	prise-dattelage-male-7-broches	Prise d’attelage mâle 7 broches – Restagraf	17433	\N	1050	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/prise-dattelage-male-7-broches/	2026-07-06 16:41:36.606947+02	2026-07-07 02:27:29.248482+02
48	repare-crevaison-1-achete-1-offert-2	Répare crevaison 1 acheté = 1 offert – Bardahl	49401	\N	1590	EUR	Regonflez et réparez instantanément votre pneu crevé avec le répare crevaison BARDAHL. Facile et rapide, il assure la mobilité temporaire de votre véhicule jusqu'au garage le plus proche. ​Ne convient pas aux pneus déchirés et aux crevaisons supérieures à 5 mm ou sur les flancs.	Description\nPour une réparation immédiate et sans démontage !\nRépare et regonfle en quelques secondes votre pneu sans outil et sans démontage.\nN’endommage pas le pneu.\nPeut être utilisé avec des valves électroniques.\nPermet de reprendre la route immédiatement.\nMode d’emploi\n1. Retirez, si possible, l’objet qui a provoqué la crevaison.\n2. Dégonflez le pneu complètement.\n3. Manoeuvrez votre véhicule pour placer l’endroit de la crevaison contre le sol.\n4. Bien agiter l’aérosol et par temps froid, le réchauffer à la main ou à l’aide de votre chauffage d’habitacle.\n5. Vissez complètement le raccord sans forcer.\n6. L’aérosol en position verticale, pulvérisez jusqu’à épuisement du produit.\n7. Lorsque le pneu est regonflé, dévissez rapidement le raccord et roulez de 6 à 8 km sans dépasser 50 km/h pour bien répartir le produit.\n8. Contrôlez et complétez la pression si nécessaire selon les préconisations du constructeur.\nPrécautions\nConsidérez cette réparation comme provisoire.\nFaites contrôler ou réparer votre pneu par un spécialiste dans les meilleurs délais.	[]	en_stock	https://pieces-auto.fr/shop/repare-crevaison-1-achete-1-offert-2/	2026-07-06 16:41:36.639342+02	2026-07-07 02:27:41.138259+02
49	repousse-piston-de-frein-coffret-de-21-pcs	Repousse piston de frein – Coffret de 21 pcs – Stilker	SOD71028	\N	1990	EUR	REPOUSSE PISTON DE FREIN – COFFRET DE 21 PCS Composition : – LH – Tourne à gauche – RH – Tourne à droite – o – Plaque de positionnement – 0 – General Motors – 1 – General Motors, PSA … En savoir plus	Description\nREPOUSSE PISTON DE FREIN – COFFRET DE 21 PCS\nComposition :\n– LH – Tourne à gauche\n– RH – Tourne à droite\n– o – Plaque de positionnement\n– 0 – General Motors\n– 1 – General Motors, PSA\n– 2 – Citroën XM, Xiantia\n– 3 – Alfa Romeo, Audi, Austin, BMW, Ford, Honda, Jaguar, Mercedes-Benz,\nMitsubishi, Nissan, Rover, Toyota, VW\n– 4 – Alfa Romeo 164 2.0, Ford, Mazda, Saab 9000, Subaru\n– 5 – Adaptateur intérieur carré 3/8″\n– 6 – Nissan Primera, VW Golf IV\n– 7 – Audi 80/90/V8 + 100, Ford Sierra ABS + Scorpio(85-xx),Honda Prelude,\nNissan Silvia 1.8 turbo, Rover 8000, Saab 9000, Subaru Legacy, VW Golf + Passat\n– 8 – General Motors GM\n– 9 – General Motors GM\n– A – Renault\n– E – Nissan Maxima\n– F – Open Astra\n– K – Citroën\n– K1 – Citroën C5 (étrier avant)\n– K2 – Audi\n– M – Ford\n– N – Saab, Honda\n21 PIÈCES	[]	en_stock	https://pieces-auto.fr/shop/repousse-piston-de-frein-coffret-de-21-pcs/	2026-07-06 16:41:36.645842+02	2026-07-07 02:27:45.485618+02
50	repousse-piston-de-frein-coffret-de-35-pcs	Repousse piston de frein – Coffret de 35 pcs – Stilker	SOD71027	\N	3590	EUR	REPOUSSE PISTON DE FREIN – COFFRET DE 35 PCS ; ce coffret contient : – 2 clés Hexagonales de 6 et 7mm – 4 plaques de réaction – 24 adaptateurs – 1 tourne à droite – 1 tourne à gauche … En savoir plus	Description\nREPOUSSE PISTON DE FREIN – COFFRET DE 35 PCS ; ce coffret contient :\n– 2 clés Hexagonales de 6 et 7mm\n– 4 plaques de réaction\n– 24 adaptateurs\n– 1 tourne à droite\n– 1 tourne à gauche\n– 1 burette pour huile\n– 1 poinçon Ø 3,0mm\n– 1 poinçon Ø 5,5mm\nComposition :\n– RH – tourne à droite\n– LH – tourne à gauche\no – Plaque de positionnement\n– 0-GM Motors\n– 1- General Motors, PSA\n– 11-disque pour Jaguar S type\n– 12-disque pour BMW mini\n– 2-Citroen XM, Xantia\n– 3-Alfa Romeo, Audi, Austin, BMW, Ford, Honda, Jaguar, Mercedes-Benz, Mitsubishi ,Nissan\n,Rover, Toyota, VW\n– 4-Alfa Romeo 164 2.0, Ford, Mazada,Saab 9000, Subaru\n-5-Adaptateur intérieur carré de 3/8″”\n– 6-Nissan Primera, VW-Golf IV\n– 7-Audi 80,90,V8 +100,Ford Sierra ABS+Scorpio 85-xx, Honda Prelude Nissan Silvia 1.8 turbo,\nRover 8000,Saab 9000,Subaru L+Z,VW-Golf +Passat 8-GM Motors\n– 8-General Motors GM\n– 9-General Motors GM\n– A-Nissan Primera 2.0,Bluebird\n– B-Ford, Lincoln, Subaru\n– C-Mini Austin\n– D- Citröen ,Renault\n– E- Nissan Maxima\n– F- Opel Astra\n– G-Opel K-Citröen C5\n– J-Alfa Romeo 155 1.8-2.0 164 TD(93) 164 3.0 V6(91) Audi,80,90,A3,A4,A6,A8 Citröen ZX 2\nQl 16V,Fiat Tipo TD 16V,Uno Turbo (85) Crama TD, Ford Sierra(ABS), Granada (85),(Australie & NZ)\nThunderbird Turbo, Honda CRX,1.6l-16V (8-90),Accord 1800(84-85)2.0i,Prelude 16V(88),Legend\nV6,Jaguar XJ40series,Lancia Dedra 2.0 Ei Tur(93),\nDelta 1.6Gti, Nissan,Peugeot,Renault,Seat,Subaru,Volvo V40& S40.\n– K – Citroën C5\n– K1 – Citroën C5 (étrier avant)\n– K2 – Audi\n– M-Ford\n– N-Saab, Honda\n– P-Audi, BMW, Ford, Lancia, Proton, Renault, Rover, VW.\n– Z-Renault\n35 PIÈCES	[]	en_stock	https://pieces-auto.fr/shop/repousse-piston-de-frein-coffret-de-35-pcs/	2026-07-06 16:41:36.653171+02	2026-07-07 02:27:49.363621+02
69	traitement-adblue	Traitement spécial AdBlue – Bardahl	SAD3152	\N	690	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/traitement-adblue/	2026-07-06 16:41:36.833131+02	2026-07-07 02:29:05.631375+02
52	sac-de-sel-de-deneigement-10kg	Sac de sel de déneigement 10KG – Synchro	SYN922451	\N	1299	EUR	Sac de sel de déneigement 10 kg – efficace pour dégager routes et allées en hiver. Facile à utiliser, idéal pour prévenir la formation de glace	Description\nChlorure de sodium d’origine espagnole obtenu par un processus d’extraction de sel gemme.\nLe produit est conforme à la norme française NF P 98-180 de juillet 2003.\nCLASSE B 1 et 2 Selon la norme NF 16811-1 : 2016\nChlorure de sodium : classe B / Humidité : Classe 1 (extra sec) / Granulométrie : Gros.\nSac avec poignée.\nIl est recommandé de conserver le produit à l’abri de l’humidité dans un endroit propre.	[]	en_stock	https://pieces-auto.fr/shop/sac-de-sel-de-deneigement-10kg/	2026-07-06 16:41:36.667212+02	2026-07-07 02:27:57.657029+02
54	shampooing-titanium-535ml	Shampoing Auto Lustrant Titanium – GS27	\N	\N	1450	EUR	Shampooing lustrant auto GS27 a intégré une formule unique dans son Shampooing Titanium® GS27 Classics alliant brillance et protection. Le Shampooing Titanium® GS27 Classics nettoie en profondeur la carrosserie éliminant les salissures, graisses et le « film routier » à l’origine du voile gras … En savoir plus	Description\nShampooing lustrant auto\nGS27 a intégré une formule unique dans son\nShampooing Titanium®\nGS27 Classics\nalliant\nbrillance et protection\n.\nLe Shampooing Titanium® GS27 Classics\nnettoie en profondeur\nla carrosserie éliminant les salissures, graisses et le « film routier » à l’origine du voile gras et terne sur les véhicules.\nLes différents composants de la formule GS27 apportent\néclat et une protection renforcée\nà votre carrosserie.\nDangereux – respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/shampooing-titanium-535ml/	2026-07-06 16:41:36.689404+02	2026-07-07 02:28:05.912468+02
55	spray-concentre-anti-martres-et-rongeurs-stop-go-difgo	Spray concentré anti-martres et rongeurs STOP & GO – DIF’GO	\N	\N	1899	EUR	Le spray anti-martres concentré permet de repousser efficacement les martres, fouines et rongeurs du compartiment moteur des véhicules, afin de prévenir les dégâts causés par ces animaux. Il peut également être utilisé pour protéger les garages, caves et greniers. Une … En savoir plus	Description\nLe spray anti-martres concentré permet de repousser efficacement les martres, fouines et rongeurs du compartiment moteur des véhicules, afin de prévenir les dégâts causés par ces animaux.\nIl peut également être utilisé pour protéger les garages, caves et greniers.\nUne application permet de traiter le véhicule pour une durée allant jusqu’à\n24 mois\n.\nCaractéristiques :\nAnti-martres à vaporiser.\nConcentré à effet longue durée, répand pour la martre une odeur “d’ennemi dangereux”.\nPas de pulvérisation à grande échelle sur tous les composants à risque, application exclusivement ponctuelle à l’aide des “accumulateurs d’odeur” à coller et à pulvériser\nrégulièrement avec le concentré parfumé.\nUsage universel dans la voiture, la maison, le jardin ou l’abri de véhicule.	[]	en_stock	https://pieces-auto.fr/shop/spray-concentre-anti-martres-et-rongeurs-stop-go-difgo/	2026-07-06 16:41:36.69661+02	2026-07-07 02:28:10.0308+02
56	tendeurs-6-pieces	Tendeurs 6 pièces – CMD	CMDA058	\N	900	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/tendeurs-6-pieces/	2026-07-06 16:41:36.7126+02	2026-07-07 02:28:13.754515+02
57	testeur-batterie-6-12v-100ah-test-de-charge-demarrage-alternateur	Testeur de batterie 6/12V 100Ah test de charge/démarrage/alternateur – Stilker	SOD04050	\N	9393	EUR	Outil complet pour tester la charge, le démarrage et l’alternateur, idéal pour diagnostiquer efficacement l’état de vos batteries 6V et 12V jusqu’à 100Ah.	Description\nTesteur de batterie Stilker 6/12V 100Ah – outil complet pour tester la charge, le démarrage et l’alternateur, idéal pour diagnostiquer efficacement l’état de vos batteries 6V et 12V jusqu’à 100Ah.\nGarantie 2 ans\nDécouvrez tous les produits de la marque\nStilker	[]	en_stock	https://pieces-auto.fr/shop/testeur-batterie-6-12v-100ah-test-de-charge-demarrage-alternateur/	2026-07-06 16:41:36.727918+02	2026-07-07 02:28:17.917362+02
58	traitement-anti-buee-pare-brise-200ml-rain-x	Traitement Anti-Buée Pare-Brise 200ml – Rain-X	INTRX26013-1	\N	1470	EUR	Dites adieu à la buée avec le traitement Rain-X Anti-Buée, la solution efficace pour prévenir la formation de buée sur les surfaces vitrées.	Description\nUn produit anti buée pour voiture indispensable pour affronter l’humidité en toute sérénité. 😎\nDécouvrez nos produits\nEntretien & Nettoyage	[]	en_stock	https://pieces-auto.fr/shop/traitement-anti-buee-pare-brise-200ml-rain-x/	2026-07-06 16:41:36.736565+02	2026-07-07 02:28:22.026959+02
61	anti-rongeurs-repulsif	Anti rongeurs répulsif – Bardahl	4492	\N	2390	EUR	L'anti rongeurs repulsif Bardahl, est une formule élaborée afin de repousser tous rongeurs. Il vous assure une haute protection action immédiate de tous vos cablages et durites.	Description\nFormule concentrée à haute qualité de répulsion. Repousse instantanément tout types de rongeurs (rats, écureuils, souris, martres etc…) Evite la détérioration par grignotage des pièces caoutchoutées et plastiques (capitonage, câbles, durits, gaines etc…) Ne blanchit pas les caoutchoucs.	[]	en_stock	https://pieces-auto.fr/shop/anti-rongeurs-repulsif/	2026-07-06 16:41:36.754946+02	2026-07-07 02:28:33.692993+02
62	anti-usure-boite-de-vitesse-manuelle	Anti usure boite de vitesse manuelle – Bardahl	1045	\N	2890	EUR	L'anti usure boite de vitesse manuelle Bardahl, prolonge la durée de vie facilite le passage des vitesses réduit les bruits.	Description\nAméliore la lubrification des roulements. Réduit la friction et l’usure. Protège de la corrosion. Facilite le passage des vitesses. Prolonge la durée de vie de la boîte de vitesse. Baisse la température de fonctionnement. Pour tout type d’huile.\nNe pas utiliser dans les boîtes de vitesse automatiques.	[]	en_stock	https://pieces-auto.fr/shop/anti-usure-boite-de-vitesse-manuelle/	2026-07-06 16:41:36.760715+02	2026-07-07 02:28:37.71129+02
63	antigel-gazole	Antigel gazole – Bardahl	2358	\N	1584	EUR	L'antigel gazole Bardahl, assure une protection antifigeante bactéricide et lubrifie pompes et injecteurs.	Description\nFormule conçue pour les motorisations fonctionnant avec du gazole “non-routier”. Protection antifigeante du gazole routier et du gazole non routier -28°C (selon le type de carburant utilisé). Facilite le démarrage à froid. Maintient les propriétés lubrifiantes du gazole à basse température. Protège du développement bactérien évitant ainsi le colmatage du filtre à carburant. Ne modifie pas l’indice de cétane du carburant.	[]	en_stock	https://pieces-auto.fr/shop/antigel-gazole/	2026-07-06 16:41:36.766536+02	2026-07-07 02:28:41.864821+02
65	b2-traitement-huile	B2 traitement huile – Bardahl	1010	\N	2545	EUR	Le b2 traitement huile Bardahl, réduit la consommation réduit les frottements plus de compressions.	Description\nRéduit les frottements. Restaure les compressions. Rétablit puissance et nervosité. Réduit la consommation d’huile et les émissions de fumées.	[]	en_stock	https://pieces-auto.fr/shop/b2-traitement-huile/	2026-07-06 16:41:36.789269+02	2026-07-07 02:28:49.873036+02
66	baume-cuir-selle-bottes-blouson	Baume cuir selle, bottes, blouson – GS27	MO140131	\N	1290	EUR	Le Baume Cuir GS27® Moto est un baume nettoyant et nourrissant pour tous les types de cuirs. Sa formule est à base de cire de carnauba. Ce produit permet de : -Redonner un coup de neuf aux cuirs ternis. -Supprimer l’effet glissant de la selle. -Laisser un film imperméabilisant et antistatique.	Description\nLe Baume Cuir GS27® Moto est un baume nettoyant et nourrissant pour tous les types de cuirs. Sa formule est à base de cire de carnauba. Ce produit permet de :\n-Redonner un coup de neuf aux cuirs ternis.\n-Supprimer l’effet glissant de la selle.\n-Laisser un film imperméabilisant et antistatique.	[]	en_stock	https://pieces-auto.fr/shop/baume-cuir-selle-bottes-blouson/	2026-07-06 16:41:36.795702+02	2026-07-07 02:28:53.62413+02
67	baume-cuir	Baume cuir – GS27	CL140132	\N	1790	EUR	Le Baume Cuir GS27 Classics® permet de nettoyer les cuirs ternis afin de leur rendre leur couleur naturelle. Grâce à sa formule enrichie en cire de carnauba, il assouplit et nourrit tous les types de cuir, les préservant et retardant ainsi leur usure. Les cuirs sont protégés et imperméabilisés durablement.	Description\nLe Baume Cuir GS27 Classics® permet de nettoyer les cuirs ternis afin de leur rendre leur couleur naturelle.\nGrâce à sa formule enrichie en cire de carnauba, il assouplit et nourrit tous les types de cuir, les préservant et retardant ainsi leur usure. Les cuirs sont protégés et imperméabilisés durablement.	[]	en_stock	https://pieces-auto.fr/shop/baume-cuir/	2026-07-06 16:41:36.801909+02	2026-07-07 02:28:57.668603+02
68	brillance-instantanee-eponge-tableau-de-bord	Éponge Brillance instantanée Tableau de bord – GS27	GM180100	\N	590	EUR	L’éponge Tableau de Bord Les Essentiels GS27® s’utilise sur tous les plastiques et cuirs et elle protège les surfaces. Son plus ? Son parfum cerise.	Description\nL’éponge Tableau de Bord Les Essentiels GS27® s’utilise sur tous les plastiques et cuirs et elle protège les surfaces. Son plus ? Son parfum cerise.	[]	en_stock	https://pieces-auto.fr/shop/brillance-instantanee-eponge-tableau-de-bord/	2026-07-06 16:41:36.816971+02	2026-07-07 02:29:01.834875+02
71	brosse-jantes-pneus-passages-de-roues	Brosse jantes & pneus passages de roues – GS27	OU180120	\N	1299	EUR	La brosse jantes et pneus, passages de roue GS27® assure un nettoyage parfait sur les surfaces planes des jantes ou les enjoliveurs. Elle est sans risque de rayures. Avec sa poignée robuste et antidérapante, ses poils souples, elle permet d’avoir une bonne prise en main ainsi qu’une efficacité redoutable. Son plus ? Elle s’utilise aussi pour nettoyer les pneus et passages de roue.	Description\nLa brosse jantes et pneus, passages de roue GS27® assure un nettoyage parfait sur les surfaces planes des jantes ou les enjoliveurs. Elle est sans risque de rayures. Avec sa poignée robuste et antidérapante, ses poils souples, elle permet d’avoir une bonne prise en main ainsi qu’une efficacité redoutable. Son plus ? Elle s’utilise aussi pour nettoyer les pneus et passages de roue.	[]	en_stock	https://pieces-auto.fr/shop/brosse-jantes-pneus-passages-de-roues/	2026-07-06 16:41:36.859732+02	2026-07-07 02:29:13.531725+02
72	burette-huile-de-precision	Burette huile de précision – Bardahl	1341	\N	564	EUR	Le burette huile de precision Bardahl, a un haut pouvoir de pénétration grâce à sa composition extra fine. De plus il est anti-corrosion	Description\nExtra fine. Haut pouvoir de pénétration. Supprime bruits et grincements. Anti – corrosion. Idéal pour les petits mécanismes.	[]	en_stock	https://pieces-auto.fr/shop/burette-huile-de-precision/	2026-07-06 16:41:36.87452+02	2026-07-07 02:29:22.991526+02
74	coffret-cire-perfection	Coffret cire perfection – GS27	CL160301	\N	4831	EUR	La Cire Perfection GS27® est issue de deux ans de recherche. Pour atteindre la perfection côté protection et brillance, la cire GS27® est un mélange de cire d'origine naturelle de qualité supérieure et de cire d'origine synthétique. L’application de la cire est simple et facile.	Description\nLa Cire Perfection GS27®  est issue de deux ans de recherche. Pour atteindre la perfection côté protection et brillance, la cire GS27® est un mélange de cire d’origine naturelle de qualité supérieure et de cire d’origine synthétique. L’application de la cire est simple et facile.	[]	en_stock	https://pieces-auto.fr/shop/coffret-cire-perfection/	2026-07-06 16:41:36.906486+02	2026-07-07 02:29:30.934744+02
75	coffret-de-decontamination	Coffret de décontamination – GS27	CL160271	\N	3520	EUR	Le Kit Décontamination GS27® permet de décontaminer la carrosserie en profondeur. Il promet d’éliminer les traces de : pollution, sève, goudron, résidus gras, traces de calcaire. Ce kit contient : 1 lubrifiant spécifique de 500ml et une gomme de décontamination. Après l’utilisation de ces deux produits, la carrosserie sera prête pour un traitement type polish, lustreur ou cire.	Description\nLe Kit Décontamination GS27® permet de décontaminer la carrosserie en profondeur. Il promet d’éliminer les traces de : pollution, sève, goudron, résidus gras, traces de calcaire. Ce kit contient : 1 lubrifiant spécifique de 500ml et une gomme de décontamination. Après l’utilisation de ces deux produits, la carrosserie sera prête pour un traitement type polish, lustreur ou cire.	[]	en_stock	https://pieces-auto.fr/shop/coffret-de-decontamination/	2026-07-06 16:41:36.922178+02	2026-07-07 02:29:34.953745+02
76	coffret-desinfectant-ventilation-climatisation-habitacle-monoi	Coffret désinfectant ventilation, climatisation & habitacle Parfum Monoï – GS27	CL160431	\N	1801	EUR	circuit d’air. De part son action, il détruit les champignons* et bactéries*, assainit l’habitacle et élimine les mauvaises odeurs. Son application est très simple, il est équipé d’un dispositif de pulvérisation à usage unique. Son plus ? Son parfum Monoï.  * Testé selon la norme EN 1276 et EN 1650. Liste des bactéries testées : pseudomonas aeruginosa, escherichia coli, staphylococcus aureus, enterococcus hirae. Dangereux - Respecter les précautions d'emploi. Utilisez les biocides avec précautions. Lisez les étiquettes et les informations concernant ce produit avant toute utilisation.	Description\ncircuit d’air. De part son action, il détruit les champignons* et bactéries*, assainit l’habitacle et élimine les mauvaises odeurs. Son application est très simple, il est équipé d’un dispositif de pulvérisation à usage unique. Son plus ? Son parfum Monoï.\n* Testé selon la norme EN 1276 et EN 1650. Liste des bactéries testées : pseudomonas aeruginosa, escherichia coli, staphylococcus aureus, enterococcus hirae.\nDangereux – Respecter les précautions d’emploi. Utilisez les biocides avec précautions. Lisez les étiquettes et les informations concernant ce produit avant toute utilisation.	[]	en_stock	https://pieces-auto.fr/shop/coffret-desinfectant-ventilation-climatisation-habitacle-monoi/	2026-07-06 16:41:36.928954+02	2026-07-07 02:29:39.015644+02
85	degrippant-a-froid-50c	Dégrippant à froid – 50°c – Bardahl	4901	\N	2995	EUR	Le dégrippant à froid - 50°c Bardahl, a une action cryogénique abaissant la température de votre pièce à -50 °c. Il produit un choc thermique et donne un effet immédiat très pénétrant.	Description\nLa pulvérisation crée un choc cryogénique intense à -50°C. Ce choc thermique permet de briser les liaisons des points de contacts oxydés. L’action “réductrice d’oxyde” prend le relai pour dégripper les assemblages les plus réclacitrants. Laisse un film lubrifiant facilitant le démontage et agissant contre l’oxydation.	[]	en_stock	https://pieces-auto.fr/shop/degrippant-a-froid-50c/	2026-07-06 16:41:37.003204+02	2026-07-07 02:30:13.875256+02
81	collier-de-vanne-egr-special-psa-16-hdi	Collier de vanne EGR	PLLPL4702	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/collier-de-vanne-egr-special-psa-16-hdi/	2026-07-06 16:41:36.970894+02	2026-07-06 16:41:36.970894+02
78	coffret-lustreur-titanium-black-intense	Coffret lustreur titanium+ black intense – GS27	CL160250	\N	3690	EUR	A base de Titanium, le Lustreur Titanium+® Black Intense GS27 Classics® est un lustreur teinteur haute protection. Les peintures noires étant particulièrement fragiles, ce lustreur est spécialement conçu pour les protéger. Son action ? Grâce à sa formule au Titanium, votre carrosserie sera protégée contre les agressions extérieures tels que : les UV, le sel, ou la pluie. En laissant une protection antistatique et hydrofuge cela va permettre de limiter l’incrustation des salissures et garantir un résultat durable. Brilllance incomparable et intensité des peintures noires garanties ! Inclus dans ce coffret : disque applicateur, microfibre, porte-clés.	Description\nA base de Titanium, le Lustreur Titanium+® Black Intense GS27 Classics® est un lustreur teinteur haute protection. Les peintures noires étant particulièrement fragiles, ce lustreur est spécialement conçu pour les protéger. Son action ? Grâce à sa formule au Titanium, votre carrosserie sera protégée contre les agressions extérieures tels que : les UV, le sel, ou la pluie. En laissant une protection antistatique et hydrofuge cela va permettre de limiter l’incrustation des salissures et garantir un résultat durable. Brilllance incomparable et intensité des peintures noires garanties !\nInclus dans ce coffret : disque applicateur, microfibre, porte-clés.	[]	en_stock	https://pieces-auto.fr/shop/coffret-lustreur-titanium-black-intense/	2026-07-06 16:41:36.942244+02	2026-07-07 02:29:46.687589+02
79	coffret-lustreur-titanium	Coffret lustreur titanium+ – GS27	CL160240	\N	3490	EUR	Le Coffret Lustreur Titanium GS27® est un produit très concentré en Titanium®. Le titanium est un composant léger est très résistant utilisé dans des secteurs de pointe comme l'aéronautique. Votre carrosserie sera encore plus brillante grâce à cette technologie. Aussi, ce lustreur protège efficacement contre les agressions extérieures (soleil, pluie, neige, sel, etc.). Inclus dans ce coffret : disque applicateur, microfibre, porte-clés.	Description\nLe Coffret Lustreur Titanium GS27® est un produit très concentré en Titanium®.\nLe titanium est un composant léger est très résistant utilisé dans des secteurs de pointe comme l’aéronautique.\nVotre carrosserie sera encore plus brillante grâce à cette technologie. Aussi, ce lustreur protège efficacement contre les agressions extérieures (soleil, pluie, neige, sel, etc.).\nInclus dans ce coffret : disque applicateur, microfibre, porte-clés.	[]	en_stock	https://pieces-auto.fr/shop/coffret-lustreur-titanium/	2026-07-06 16:41:36.954939+02	2026-07-07 02:29:50.700211+02
80	colle-retroviseur	Colle pour rétroviseur – Bardahl	49931	\N	1050	EUR	Le Colle rétroviseur Bardahl, est spécialement conçue pour réparations où l'on rencontre de fortes vibrations. De plus, cette colle ne déborde pas et ne salie pas vos mirroirs.	Description\nSe compose d’une colle anaérobie et d’une maille nylon imprégnée qui sert de catalyseur. Recommandé pour les embases de rétrovisuers, verrous de déflecteurs, custodes, … tenue en température de -50°C à +130°C. Haute résistence à la traction et aux vibrations.	[]	en_stock	https://pieces-auto.fr/shop/colle-retroviseur/	2026-07-06 16:41:36.964001+02	2026-07-07 02:29:54.409565+02
82	decrassant-plastiques	Décrassant plastiques – GS27	CL120172	\N	1290	EUR	Le Décrassant Plastiques GS27 Classics® permet de nettoyer les plastiques fortement encrassés, jaunis ou altérés par la chaleur, la poussière, la fumée de cigarette. De part sa puissante action, il va raviver vos plastiques tout en laissant une finition brillante. Aussi, Il enlèvera les traces blanches dues à des applications de lustreurs ou des cires sur les plastiques extérieurs. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Décrassant Plastiques GS27 Classics® permet de nettoyer les plastiques fortement encrassés, jaunis ou altérés par la chaleur, la poussière, la fumée de cigarette. De part sa puissante action, il va raviver vos plastiques tout en laissant une finition brillante. Aussi, Il enlèvera les traces blanches dues à des applications de lustreurs ou des cires sur les plastiques extérieurs. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/decrassant-plastiques/	2026-07-06 16:41:36.978768+02	2026-07-07 02:30:02.456586+02
83	degivrant-300-100-ml-offerts-holts	Dégivrant 300 ml + 100 ml OFFERTS – Holts	HOL208181	\N	405	EUR	Dégivrant HOLTS 300ml + 100 ml GRATUITS Dégivre efficacement les surfaces vitrées jusqu’à -25°C. Limite la réapparition du givre, sans trace. Pulvérisation large et rapidité d’action	Description\nDégivrant HOLTS 300ml + 100 ml GRATUITS Dégivre efficacement les surfaces vitrées jusqu’à -25°C. Limite la réapparition du givre, sans trace. Pulvérisation large et rapidité d’action	[]	en_stock	https://pieces-auto.fr/shop/degivrant-300-100-ml-offerts-holts/	2026-07-06 16:41:36.986084+02	2026-07-07 02:30:06.177688+02
84	degivrant-vitres-et-serrures-bardahl	Dégivrant spécial vitres et serrures – Bardahl	4912	\N	690	EUR	Action immédiate, spécial Grand froid -25°  Format maxi 750ml Vitres - serrures - fini la corvée du dégrivrage en hiver au petit matin! Dégivrant pare brise, vitres latérales, rétroviseurs et serrures, à action immédiate et sans traces.	Description\nPermet de dégivrer sans difficulté, même par grand froid. Assure de partir rapidement, dans de bonnes conditions de visibilité.	[]	en_stock	https://pieces-auto.fr/shop/degivrant-vitres-et-serrures-bardahl/	2026-07-06 16:41:36.995565+02	2026-07-07 02:30:10.211591+02
89	deocar-maxxx-bubble-gum	Déocar maxxx Parfum bubble gum – GS27	AC180049	\N	750	EUR	Le Déocar Maxxx Bubble Gum est doté d’une coque spécifique qui permet d’ajuster à votre guise la diffusion du parfum en ouvrant plus ou moins l’ouverture à l’arrière de la coque. Et donc de pouvoir doser facilement l’intensité du parfum. Ce désodorisant se fixe sur la grille d’aération pour diffuser ses senteurs dans tout l’habitacle par le système de ventilation. Sa petite fenêtre à l’avant indique le niveau de parfum restant. Son efficacité dure 60 jours. Parfum : bubble gum.	Description\nLe Déocar Maxxx Bubble Gum est doté d’une coque spécifique qui permet d’ajuster à votre guise la diffusion du parfum en ouvrant plus ou moins l’ouverture à l’arrière de la coque. Et donc de pouvoir doser facilement l’intensité du parfum. Ce désodorisant se fixe sur la grille d’aération pour diffuser ses senteurs dans tout l’habitacle par le système de ventilation. Sa petite fenêtre à l’avant indique le niveau de parfum restant. Son efficacité dure 60 jours.\nParfum : bubble gum.	[]	en_stock	https://pieces-auto.fr/shop/deocar-maxxx-bubble-gum/	2026-07-06 16:41:37.043628+02	2026-07-07 02:30:30.604567+02
90	deocar-maxxx-cerise	Déocar maxxx Parfum cerise – GS27	AC180047	\N	750	EUR	Le Déocar Maxxx Bubble Gum est doté d’une coque spécifique qui permet d’ajuster à votre guise la diffusion du parfum en ouvrant plus ou moins l’ouverture à l’arrière de la coque. Et donc de pouvoir doser facilement l’intensité du parfum. Ce désodorisant se fixe sur la grille d’aération pour diffuser ses senteurs dans tout l’habitacle par le système de ventilation. Sa petite fenêtre à l’avant indique le niveau de parfum restant. Son efficacité dure 60 jours. Parfum : cerise.	Description\nLe Déocar Maxxx Bubble Gum est doté d’une coque spécifique qui permet d’ajuster à votre guise la diffusion du parfum en ouvrant plus ou moins l’ouverture à l’arrière de la coque. Et donc de pouvoir doser facilement l’intensité du parfum. Ce désodorisant se fixe sur la grille d’aération pour diffuser ses senteurs dans tout l’habitacle par le système de ventilation. Sa petite fenêtre à l’avant indique le niveau de parfum restant. Son efficacité dure 60 jours.\nParfum : cerise.	[]	en_stock	https://pieces-auto.fr/shop/deocar-maxxx-cerise/	2026-07-06 16:41:37.050809+02	2026-07-07 02:30:34.617492+02
91	deocar-origin-monoi	Déocar Origin Parfum Monoï – GS27	AC180012	\N	650	EUR	Déocar® Orign est un nouveau concept de parfum d’intérieur automobile.  En s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours. Parfum : monoï.	Description\nDéocar® Orign est un nouveau concept de parfum d’intérieur automobile.\nEn s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours.\nParfum : monoï.	[]	en_stock	https://pieces-auto.fr/shop/deocar-origin-monoi/	2026-07-06 16:41:37.058592+02	2026-07-07 02:30:38.716318+02
100	detecteur-de-fuite-flacon	Détecteur de fuite flacon – Bardahl	4250	\N	8213	EUR	Le détecteur de fuite en flacon Bardahl est une formule prête à l'emploi et qui réagit avec un traceur UV.	Description\nDétecte rapidement les fuites même sur un compartiment moteur sale. Economique à l’utilisation, 1 flacon traite 50 circuits. S’utilise avec toutes les stations de recharges équipées d’une circuit d’injection de traceur et les seringues d’injection. Sans solvant.	[]	en_stock	https://pieces-auto.fr/shop/detecteur-de-fuite-flacon/	2026-07-06 16:41:37.168186+02	2026-07-07 02:31:14.652898+02
125	graisse-tout-usage-en-cartouche	Graisse tout usage en cartouche – Bardahl	1528	\N	1090	EUR	La graisse tout usage en cartouche Bardahl, assure une lubrification optimale grâce à ses propriétés anti-usure et de longue durée.	Description\nExcellente adhérence. Résiste à l’eau, à l’oxydation, à la chaleur et au vieillissement prématuré. Anti-usure, extrême pression, anti-corrosion et anti cisaillement.Graisse universelle au lithium. Compatible toute pompe à graisse.	[]	en_stock	https://pieces-auto.fr/shop/graisse-tout-usage-en-cartouche/	2026-07-06 16:41:37.426551+02	2026-07-07 02:32:55.37171+02
225	tuyau-dechappement	Tuyau d’échappement	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/tuyau-dechappement/	2026-07-06 16:41:38.358307+02	2026-07-06 16:41:38.358307+02
93	deocar-origin-pomme-verte	Déocar origin Parfum Pomme verte – GS27	AC180016	\N	650	EUR	Déocar® Orign est un nouveau concept de parfum d’intérieur automobile.  En s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours. Parfum : pomme verte.	Description\nDéocar® Orign est un nouveau concept de parfum d’intérieur automobile.\nEn s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours.\nParfum : pomme verte.	[]	en_stock	https://pieces-auto.fr/shop/deocar-origin-pomme-verte/	2026-07-06 16:41:37.072294+02	2026-07-07 02:30:47.020849+02
94	deocar-spray-cerise	Déocar spray Parfum cerise – GS27	AC180037	\N	550	EUR	Parfumez votre intérieur de voiture selon vos envies avec le Déocar® Spray. Avec le Déocar® Spray c’est vous qui choisissez le nombre de pulvérisations et donc l’intensité du parfum en fonction de votre goût et de la taille de votre véhicule. Sur la base de deux pulvérisations par jour, le Déocar® Spray a une efficacité de 150 jours sur la base de 2 pulvérisations / jour. Parfum : cerise.	Description\nParfumez votre intérieur de voiture selon vos envies avec le Déocar® Spray.\nAvec le Déocar® Spray c’est vous qui choisissez le nombre de pulvérisations et donc l’intensité du parfum en fonction de votre goût et de la taille de votre véhicule. Sur la base de deux pulvérisations par jour, le Déocar® Spray a une efficacité de 150 jours sur la base de 2 pulvérisations / jour.\nParfum : cerise.	[]	en_stock	https://pieces-auto.fr/shop/deocar-spray-cerise/	2026-07-06 16:41:37.092851+02	2026-07-07 02:30:50.953288+02
95	deocar-spray-fleur-de-lotus	Déocar spray Parfum fleur de lotus – GS27	AC180031	\N	550	EUR	Parfumez votre intérieur de voiture selon vos envies avec le Déocar® Spray. Avec le Déocar® Spray c’est vous qui choisissez le nombre de pulvérisations et donc l’intensité du parfum en fonction de votre goût et de la taille de votre véhicule. Sur la base de deux pulvérisations par jour, le Déocar® Spray a une efficacité de 150 jours sur la base de 2 pulvérisations / jour. Parfum : fleur de lotus.	Description\nParfumez votre intérieur de voiture selon vos envies avec le Déocar® Spray.\nAvec le Déocar® Spray c’est vous qui choisissez le nombre de pulvérisations et donc l’intensité du parfum en fonction de votre goût et de la taille de votre véhicule. Sur la base de deux pulvérisations par jour, le Déocar® Spray a une efficacité de 150 jours sur la base de 2 pulvérisations / jour.\nParfum : fleur de lotus.	[]	en_stock	https://pieces-auto.fr/shop/deocar-spray-fleur-de-lotus/	2026-07-06 16:41:37.112369+02	2026-07-07 02:30:54.982298+02
96	depart-moteur-essence-diesel	Départ moteur Essence & Diesel – Bardahl	4562	\N	1390	EUR	Le départ moteur Essence & Diesel Bardahl permet un démarrage instantané lorsque votre moteur refuse de coopérer ! La combustion est instantannée et ne nécessite pas de démontage. Vous gagnez du temps !	Description\nAssure un démarrage instantané des moteurs 2 et 4 temps. Assure une combustion parfaite et un fonctionnement normal par tous les temps. Solutionne et traite les problèmes de démarrage difficile.	[]	en_stock	https://pieces-auto.fr/shop/depart-moteur-essence-diesel/	2026-07-06 16:41:37.130355+02	2026-07-07 02:30:58.737204+02
97	depoussierant-sec-neutre	Dépoussiérant sec & neutre – Bardahl	4449	\N	2590	EUR	Le depoussierant sec & neutre Bardahl, est très puissant, sans odeur et neutre pour l'environnement.	Description\nGaz comprimé très puissant, neutre et sans odeurs. Sans impuretés (garantit à 99.9%). Dépoussière et sèche complètement tout matériel ou surface d’accès difficile. Assure un fonctionnement optimal des claviers d’ordianteurs.	[]	en_stock	https://pieces-auto.fr/shop/depoussierant-sec-neutre/	2026-07-06 16:41:37.145456+02	2026-07-07 02:31:02.740973+02
98	deshuilant-radiateur	Déshuilant radiateur – Bardahl	1100	\N	2545	EUR	Le deshuilant radiateur Bardahl, action dégraissante immédiate et anti-surchauffe	Description\nEmulsionne l’huile et permet ainsi l’évacuation totale de tout type de dépôt. Assure un nettoyage parfait. Assure un fonctionnement optimal.	[]	en_stock	https://pieces-auto.fr/shop/deshuilant-radiateur/	2026-07-06 16:41:37.153647+02	2026-07-07 02:31:06.854166+02
99	detachant-resines	Détachant résines – GS27	CL120191	\N	1190	EUR	Le Détachant Résines GS27 Classics® va permettre de dissoudre très aisément toutes les taches de résines de conifères : pin, sapin, mélèze, thuya, séquoia, cèdre etc. Il est efficace à la fois sur toutes les peintures de carrosserie mais également sur les vitres, chromes, plastiques et polyester. Dangereux – veillez à respecter les précautions d'emploi	Description\nLe Détachant Résines GS27 Classics® va permettre de dissoudre très aisément toutes les taches de résines de conifères : pin, sapin, mélèze, thuya, séquoia, cèdre etc. Il est efficace à la fois sur toutes les peintures de carrosserie mais également sur les vitres, chromes, plastiques et polyester.\nDangereux – veillez à respecter les précautions d’emploi	[]	en_stock	https://pieces-auto.fr/shop/detachant-resines/	2026-07-06 16:41:37.162219+02	2026-07-07 02:31:10.602996+02
102	disques-de-frein	Disques de frein	\N	\N	0	EUR	Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nLa sécurité avant tout\nLes freins à disque doivent résister à de très fortes contraintes mécaniques et thermiques. Les matériaux haute qualité qui composent nos freins à disque  leurs permettent de résister à des contraintes extrêmes avec une fiabilité totale.\nLors d’un freinage brusque, la puissance de freinage est largement supérieure à celle développée par le moteur. La température entre les plaquettes et le disque de frein peut alors dépasser 750 °C, seuls des composants de qualité supérieure sont capables de résister durablement à de telles sollicitations	[]	en_stock	https://pieces-auto.fr/shop/disques-de-frein/	2026-07-06 16:41:37.181212+02	2026-07-06 16:41:37.181212+02
109	embrayage	Embrayage	\N	\N	0	EUR	Nous disposons de tous les embrayages, volants moteurs bi-masses, butées hydrauliques et tous les accessoires liés à l'embrayage de votre véhicule.  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nLes kits traditionnels premium 2 pièces ou 3 pièces\nLes kits traditionnels pour applications asiatiques\nLes kits traditionnels pour VUL (<3.5T)\nLes Kits traditionnels 3 pièces + CSC	[]	en_stock	https://pieces-auto.fr/shop/embrayage/	2026-07-06 16:41:37.262256+02	2026-07-06 16:41:37.262256+02
103	double-face-transparent-19-mm-x-2-m	Double face transparent (19 mm x 2 m) – Bardahl	4998	\N	745	EUR	Le double face transparent (19 mm x 2 m) Bardahl assure robustesse et durabilité.	Description\nAdhésif double face en résine acrylique. Il résiste à l’eau et aux températures extrêmes (de -30°C à +120°C).	[]	en_stock	https://pieces-auto.fr/shop/double-face-transparent-19-mm-x-2-m/	2026-07-06 16:41:37.206955+02	2026-07-07 02:31:26.646667+02
104	efface-rayures-gris	Efface rayures gris – GS27	CL150161	\N	1290	EUR	Pour traiter les rayures superficielles de type éraflures ou griffures sur un véhicule gris, l'Efface Rayures Gris GS27 Classics® est le produit le plus adapté. Il est pratique et facile à appliquer grâce à sa formule crème. Il est composé de microcristaux de pigments gris, qui vont permettre de faire disparaitre les traces de rayures ainsi que d'uniformiser la couleur de la peinture grise sur la zone endommagée.	Description\nPour traiter les rayures superficielles de type éraflures ou griffures sur un véhicule gris, l’Efface Rayures Gris GS27 Classics® est le produit le plus adapté. Il est pratique et facile à appliquer grâce à sa formule crème. Il est composé de microcristaux de pigments gris, qui vont permettre de faire disparaitre les traces de rayures ainsi que d’uniformiser la couleur de la peinture grise sur la zone endommagée.	[]	en_stock	https://pieces-auto.fr/shop/efface-rayures-gris/	2026-07-06 16:41:37.220476+02	2026-07-07 02:31:30.727723+02
105	efface-rayures-noir	Efface rayures noir – GS27	CL150151	\N	1290	EUR	Pour traiter les rayures superficielles sur un véhicule noir de type éraflures, griffures, l'Efface Rayures Noir GS27 Classics® est le produit le plus adapté. Facile et pratique à utiliser notamment grâce à sa formule crème. Composé de microcristaux de pigments noirs, l’Efface Rayures Noir GS27 Classics® va faire disparaitre les traces de rayures ainsi qu’uniformiser la couleur de la peinture noire sur la zone abimée.	Description\nPour traiter les rayures superficielles sur un véhicule noir de type éraflures, griffures, l’Efface Rayures Noir GS27 Classics® est le produit le plus adapté. Facile et pratique à utiliser notamment grâce à sa formule crème. Composé de microcristaux de pigments noirs, l’Efface Rayures Noir GS27 Classics® va faire disparaitre les traces de rayures ainsi qu’uniformiser la couleur de la peinture noire sur la zone abimée.	[]	en_stock	https://pieces-auto.fr/shop/efface-rayures-noir/	2026-07-06 16:41:37.233143+02	2026-07-07 02:31:34.829695+02
106	efface-rayures-profondes	Efface rayures profondes – GS27	CA100122	\N	1690	EUR	L'Efface Rayures Profondes GS27® Classics permet de faire disparaitre des rayures profondes ayant une incision importante dans la couche de vernis. Sa formule active gomme les bords incisifs de la rayure. Les microparticules lissantes vont quant à elles polir les bords de la rayure afin d’atténuer l’angle de réflexion de la lumière et donc effacer l’incision. Ce produit s’applique avec une microfibre ce qui permet une action localisée.	Description\nL’Efface Rayures Profondes GS27® Classics permet de faire disparaitre des rayures profondes ayant une incision importante dans la couche de vernis. Sa formule active gomme les bords incisifs de la rayure. Les microparticules lissantes vont quant à elles polir les bords de la rayure afin d’atténuer l’angle de réflexion de la lumière et donc effacer l’incision. Ce produit s’applique avec une microfibre ce qui permet une action localisée.	[]	en_stock	https://pieces-auto.fr/shop/efface-rayures-profondes/	2026-07-06 16:41:37.241588+02	2026-07-07 02:31:38.636769+02
107	efface-rayures-titanium	Efface rayures titanium – GS27	CL150141	\N	1390	EUR	Traitez vos rayures superficielles (éraflures, griffures, etc) avec l’Efface Rayures Titanium® GS27 Classics®. Sa crème à base de microbilles et de cristaux microscopiques lamellaires, et sa formule enrichie en Titanium® permettent d’améliorer l’efficacité du gommage, de renforcer la protection des parties traitées et de garantir une finition brillante.	Description\nTraitez vos rayures superficielles (éraflures, griffures, etc) avec l’Efface Rayures Titanium® GS27 Classics®. Sa crème à base de microbilles et de cristaux microscopiques lamellaires, et sa formule enrichie en Titanium® permettent d’améliorer l’efficacité du gommage, de renforcer la protection des parties traitées et de garantir une finition brillante.	[]	en_stock	https://pieces-auto.fr/shop/efface-rayures-titanium/	2026-07-06 16:41:37.248814+02	2026-07-07 02:31:42.748692+02
108	efface-rayures-universel	Efface rayures universel – GS27	CL150131	\N	1090	EUR	Eliminez vos rayures superficielles de type éraflures, griffures, avec l'Efface Rayures Universel GS27 Classics®. Avec sa crème à base de cristaux microscopiques il va vous permettre de traiter vous-même la surface endommagée de votre carrosserie. Produit simple à utiliser.	Description\nEliminez vos rayures superficielles de type éraflures, griffures, avec l’Efface Rayures Universel GS27 Classics®. Avec sa crème à base de cristaux microscopiques il va vous permettre de traiter vous-même la surface endommagée de votre carrosserie. Produit simple à utiliser.	[]	en_stock	https://pieces-auto.fr/shop/efface-rayures-universel/	2026-07-06 16:41:37.255581+02	2026-07-07 02:31:47.856335+02
112	filtre-a-air	Filtre à air	\N	\N	0	EUR	Pour un moteur en bonne santé : Filtres à air Bosch Fonction du filtre à air  - Protection du moteur contre les salissures contenues dans l'air aspiré  - Protection du moteur contre l'usure  - Garantit l'arrivée d'air requise pour la préparation du mélange  - Diminution du bruit  Le filtre à air doit être remplacé régulièrement conformément aux indications des constructeurs automobiles !  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nUn filtre obstrué a les conséquences suivantes :\nPréparation du mélange air-carburant médiocre, entraînant une baisse de la puissance du moteur et une hausse du rejet de polluants\nAugmentation de la consommation de carburant\nUsure accrue du moteur par les particules\nProblèmes lors du démarrage de votre véhicule\nConditions requises pour un fonctionnement optimal : Etanchéité\nEn cas de fuite ou de porosité du filtre, l’air non filtré (air parasite) est conduit vers le canal d’aspiration. C’est pourquoi les filtres à air Bosch bénéficient d’un dispositif d’étanchéité longue durée en polyuréthane :\nAdaptés sur mesure à la forme du boîtier\nLes aspérités du boîtier sont gommées\nLe joint reste flexible et élastique sur l’ensemble de la durée de vie du filtre	[]	en_stock	https://pieces-auto.fr/shop/filtre-a-air/	2026-07-06 16:41:37.280836+02	2026-07-06 16:41:37.280836+02
113	filtre-a-huile	Filtre à huile	\N	\N	0	EUR	Pour que votre moteur carbure à plein régime  Fonction du filtre à huile  Protection du moteur contre les impuretés contenues dans l'huile  Le filtre à huile doit être remplacé régulièrement conformément aux indications des constructeurs automobiles !  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nUn filtre obstrué a les conséquences suivantes :\nUsure précoce du moteur pouvant provoquer un endommagement du moteur\nPuissance moteur réduite\nConsommation d’huile accrue\nFuites d’huile\nLa conduite en ville met l’huile à rude épreuve\nEn cas de petits trajets et de démarrages et arrêts répétés, les intervalles de remplacement de l’huile et du filtre à huile doivent être plus courts que ceux prescrits par les constructeurs automobiles. Les démarrages à froid répétés entraînent la formation accrue d’eau de condensation ainsi qu’un excès de carburant dans le mélange combustible. Concrètement, cela signifie que …\n… des hydrocarbures non consumés et de l’eau de condensation se retrouvent dans l’huile, provoquant son vieillissement précoce\n… lorsque le moteur fonctionne à haute température, ces composants s’évaporent dans le circuit d’huile, abaissant de ce fait la qualité de la lubrification	[]	en_stock	https://pieces-auto.fr/shop/filtre-a-huile/	2026-07-06 16:41:37.288606+02	2026-07-06 16:41:37.288606+02
114	filtre-dhabitacle	Filtre d’habitacle	\N	\N	0	EUR	Plus de confort, plus de sécurité et une santé préservée ! Fonctions du filtre d'habitacle à charbon actif  - Protection des passagers du véhicule contre le pollen, la poussière et les polluants  - Protection contre les gaz nocifs et malodorants  - Protection du climatiseur  Le filtre d'habitacle à charbon actif doit être remplacé tous les 15 000 km ou tous les ans !  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nFiltre d’habitacle à charbon actif Bosch\nTrois couches de fibres plus une couche de charbon actif\nLa charge électrostatique permet à la couche de fibres centrale composée de microfibres chargées en électricité statique d’attirer les plus fines particules respirables et de les filtrer de l’air\nFonctionnement fiable de -40 à +85 °C\nAbsorption des odeurs et des gaz nocifs par la couche de charbon actif\nLa couche de charbon actif\nMatériau naturel à base de coquilles de noix de coco carbonisées et concassées à l’abri de l’air\nFormation de la structure spongieuse dans la vapeur d’eau (jusqu’à 800 °C)\nSurface énorme : 1 g de charbon actif possède une surface intérieure d’env. 1 000 m\n2\n1 cuillère à café de charbon actif équivaut à la surface d’un terrain de football	[]	en_stock	https://pieces-auto.fr/shop/filtre-dhabitacle/	2026-07-06 16:41:37.295608+02	2026-07-06 16:41:37.295608+02
115	filtre-diesel	Filtre diesel	\N	\N	0	EUR	Une protection indispensable pour les systèmes d'injection  Fonction du filtre diesel :  Protège le système d'injection et le moteur contre les particules, l'eau et les autres résidus contenus dans le carburant  Le filtre diesel doit être remplacé régulièrement conformément aux indications des constructeurs automobiles !  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nUn filtre obstrué a les conséquences suivantes :\nPerte de puissance du moteur pouvant aller jusqu’à l’arrêt du moteur\nAltération ou interruption de l’arrivée de carburant\nDégradation des performances de la pompe à carburant pouvant entraîner un court-circuit\nUsure aggravée\nCorrosion interne des composants du moteur\nLe composant idéal pour le biodiesel : Filtre diesel Bosch\nCaractéristiques du biodiesel :\nEffet agressif sur l’élastomère et les matériaux des joints\n« Saponification » du carburant\nFaible séparation d’eau\nObstruction rapide du filtre diesel\nCroissance accrue de micro-organismes\nGrâce aux matériaux résistants mis en œuvre sur les joints et les boîtiers, à des milieux filtrants de première qualité et à une séparation d’eau améliorée, les filtres diesel Bosch constituent également la solution idéale en cas d’utilisation de biodiesel.	[]	en_stock	https://pieces-auto.fr/shop/filtre-diesel/	2026-07-06 16:41:37.302838+02	2026-07-06 16:41:37.302838+02
111	extra-glue	Extra glue – Bardahl	49921	\N	1890	EUR	La colle Extra glue Bardahl est une colle extraforte monocomposant. Cette colle multi-usage viendra à bout de toutes vos petites réparation et est compatible tous matériaux.	Description\nColle Méthacrylate de méthyle de couleur blanche. Bi composant super puissant, colle en 10 mn. Résiste à l’eau. Haute tenue aux températures de -55°C à +120°C. Comble des fissures jusqu’à 10mm.	[]	en_stock	https://pieces-auto.fr/shop/extra-glue/	2026-07-06 16:41:37.274679+02	2026-07-07 02:31:59.573164+02
227	purifiant-habitacle	Purifiant habitacle – Bardahl	4402	\N	1758	EUR	Le Purifiant habitacle Bardahl purifie l'atmosphère de l'habitacle et détruit les mauvaises odeurs tout en parfumant légèrement.	Description\nPurifie l’atmosphère de l’habitacle. Supprime les odeurs. Détruit les odeurs due à la prolifération bactérienne. Elimine durablement acariens et bactéries. Parfume légèrement votre habitacle.	[]	en_stock	https://pieces-auto.fr/shop/purifiant-habitacle/	2026-07-06 16:41:38.423963+02	2026-07-07 02:39:44.507488+02
116	filtre-essence	Filtre essence	\N	\N	0	EUR	Filtration efficace des particules les plus fines  Fonction du filtre essence :  Protège le système d'injection et le moteur contre les particules et les autres résidus contenus dans le carburant  Le filtre essence doit être remplacé régulièrement conformément aux indications des constructeurs automobiles !  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nUn filtre obstrué a les conséquences suivantes :\nPerte de puissance du moteur\nAltération ou interruption de l’arrivée de carburant\nDégradation des performances de la pompe à carburant pouvant entraîner un court-circuit\nUsure aggravée\nFiltre de conduite essence pour moteurs à carburateur\nPour éviter toute difficulté au démarrage et empêcher un mauvais fonctionnement du moteur, des filtres de conduite essence sont utilisés pour les moteurs à carburateur. Ils protègent les injecteurs contre les impuretés.\nFiltre essence pour systèmes d’injection électroniques\nLes particules, même de petites dimensions, peuvent provoquer une usure importante du système d’injection de votre véhicule. Pour garantir un fonctionnement optimal et une grande longévité des composants, les filtres essence Bosch filtrent les petites impuretés de l’ordre du millième de millimètre.	[]	en_stock	https://pieces-auto.fr/shop/filtre-essence/	2026-07-06 16:41:37.309488+02	2026-07-06 16:41:37.309488+02
118	full-metal	Full métal – Bardahl	2007	\N	4290	EUR	Le full metal Bardahl, a une action anti-usure préventive et curative très puissante. Il empêche également l'encrassement prématuré.	Description\nRétablit l’étanchéité piston/paroi du cylindre. Réduit la consommation d’huile et de carburant. Améliore souplesse, reprise et accélération. Augmente rendement et puissance moteur. Ne bouche pas le filtre à huile. Compatible tout type d’huile et tout type de motorisation.	[]	en_stock	https://pieces-auto.fr/shop/full-metal/	2026-07-06 16:41:37.338817+02	2026-07-07 02:32:27.007519+02
120	graisse-blanche	Graisse blanche – Bardahl	1381	\N	995	EUR	La graisse blanche Bardahl est insoluble à l'eau, super adhésive et a une longue durée de vie.	Description\nPour tout type de support. Protège de la corrosion et de la rouille. Supprime bruits et grincements. Facilite le montage et le démontage. Protège durablement.	[]	en_stock	https://pieces-auto.fr/shop/graisse-blanche/	2026-07-06 16:41:37.379988+02	2026-07-07 02:32:35.070286+02
122	graisse-cuivre	Graisse cuivre – Bardahl	1533	\N	1250	EUR	La graisse cuivre Bardahl, haute température est efficace entre les températures de -20 °c à  +1100 °c. Elle est également conducteur électrique et a un pouvoir anti grippant	Description\nGraisse de montage haute température à base de poudre cuivrée. Evite le grippage des pièces mécaniques de -20°C à +1100°C (goujons, bougies, injecteurs, flasques de freins, échappement, embrayage etc…). Insoluble à l’eau, la graisse cuivrée assure les contacts et évite l’apparition des oxydes de rouille.	[]	en_stock	https://pieces-auto.fr/shop/graisse-cuivre/	2026-07-06 16:41:37.407295+02	2026-07-07 02:32:42.978843+02
123	graisse-multifonctions-adhesive-filante	Graisse multifonctions adhésive & filante – Bardahl	1388	\N	2350	EUR	La graisse multifonctions adhésive & filante Bardahl est une graisse spécial exterieur longue durée et anti-usure.	Description\nAnti-usure, anti-corrosion, anti-friction. Formule super pénétrante et adhérente. Résiste aux hautes températures. N’attaque pas les caoutchoucs. Pour tout type de support. Formule sans silicone, incolore et écologique.	[]	en_stock	https://pieces-auto.fr/shop/graisse-multifonctions-adhesive-filante/	2026-07-06 16:41:37.414706+02	2026-07-07 02:32:47.075379+02
124	graisse-silicone	Graisse silicone – Bardahl	1532	\N	2050	EUR	La graisse silicone Bardahl, assure une lubrification optimale grâce à ses propriétés techniques. Il est également très propre et sans odeurs tout en étant insoluble à  l'eau et aux températures de -50 °c à  +220 °c.	Description\nLubrifie sans tacher. Protège contre l’humidité et assure une étanchéité parfaite. Isole électriquement. Utilisable au contact de l’eau destinée à la consommation humaine. Pour tout type de support métallique ou plastique.	[]	en_stock	https://pieces-auto.fr/shop/graisse-silicone/	2026-07-06 16:41:37.420757+02	2026-07-07 02:32:51.087759+02
127	graisse-verte-marine	Graisse verte marine – Bardahl	1791	\N	796	EUR	La graisse verte marine Bardahl est une graisse marine universelle.	Description\nRésiste à l’eau, au sel et à l’humidité.Protège contre le grippage, la corrosion et l’oxydation.\nFacilite le démontage. Anti usure, extrême pression et anti cisaillement.\nProlonge la durée de vie des pièces lubrifiées.	[]	en_stock	https://pieces-auto.fr/shop/graisse-verte-marine/	2026-07-06 16:41:37.458115+02	2026-07-07 02:33:03.815268+02
128	huile-boites-et-ponts-xtg-75w80-ep-100-synthese-gl-4-gl-5-mt-1-2	Huile boites et ponts XTG 75w80 ep 100 % synthèse gl-4/gl-5/mt-1 – Bardhal	36373	\N	7560	EUR	L'huile boites et ponts XTG 75w80 ep 100 % synthèse gl-4/gl-5/mt-1 Bardahl, est une huile 100% Synthétique à haut pouvoir lubrifiant	Description\nHuile de synthèse extrême pression renforcée, « Total Drive Line » formulée pour la lubrification des transmissions mécaniques, des différentiels, des boites de vitesses fonctionnant dans des conditions très sévères (charges, vitesses et températures élevées). La XTG 75W80 BARDAHL est particulièrement adaptée aux engrenages hypoïdes très chargés	[]	en_stock	https://pieces-auto.fr/shop/huile-boites-et-ponts-xtg-75w80-ep-100-synthese-gl-4-gl-5-mt-1-2/	2026-07-06 16:41:37.470456+02	2026-07-07 02:33:07.77228+02
129	huile-boites-et-ponts-xtg-75w80-ep-100-synthese-gl-4-gl-5-mt-1	Huile boites et ponts XTG 75w80 ep 100 % synthèse gl-4/gl-5/mt-1 – Bardahl	36371	\N	1735	EUR	L'huile boites et ponts XTG 75w80 ep 100 % synthèse gl-4/gl-5/mt-1 Bardahl, est une huile 100% Synthétique à haut pouvoir lubrifiant	Description\nHuile de synthèse extrême pression renforcée, « Total Drive Line » formulée pour la lubrification des transmissions mécaniques, des différentiels, des boites de vitesses fonctionnant dans des conditions très sévères (charges, vitesses et températures élevées). La XTG 75W80 BARDAHL est particulièrement adaptée aux engrenages hypoïdes très chargés	[]	en_stock	https://pieces-auto.fr/shop/huile-boites-et-ponts-xtg-75w80-ep-100-synthese-gl-4-gl-5-mt-1/	2026-07-06 16:41:37.48522+02	2026-07-07 02:33:11.90928+02
130	huile-boites-et-ponts-xtg-85w140-ep-minerale-gl-5	Huile boites et ponts XTG 85w140 ep minérale gl-5 – Bardahl	36393	\N	4960	EUR	L'huile boites et ponts XTG 85w140 ep minérale gl-5 Bardahl, est une huile 100% Minérale à haut pouvoir lubrifiant	Description\nHuile minérale extrême pression formulée pour la lubrification des engrenages à fortes charges : ponts, boîtes de vitesses, réductions finales, boîtes de transfert. La XTG 85W140 BARDAHL est particulièrement adaptée aux engrenages hypoïdes très chargés en automobile, dans le TP et l’agricole.	[]	en_stock	https://pieces-auto.fr/shop/huile-boites-et-ponts-xtg-85w140-ep-minerale-gl-5/	2026-07-06 16:41:37.499565+02	2026-07-07 02:33:15.813504+02
131	huile-de-coupe-et-percage	Huile de coupe et perçage – Bardahl	44612	\N	1090	EUR	Huile de coupe et perçage Bardahl – Lubrification optimale pour des opérations de coupe et perçage. Protégez vos outils et prolongez leur durée de vie.	Description\nL’huile de coupe et perçage Bardahl est spécialement étudiée pour lubrifier votre perçage à haute température afin de protéger vos forets ou mèches.\nCaractéristiques :\nLubrifie et refroidit les outils de découpe et d’usinage\nRésiste aux températures extrêmes pressions et aux températures élevées\nConçu pour taraudage, fraisage, perçage et décapage\nEvite l’usure prématurée des outillages.\nDiminue l’encrassement.\nIdéal pour aciers spéciaux, inox, alliage, aluminium, laiton.\nDécouvre tous nos produits\nBardhal	[]	en_stock	https://pieces-auto.fr/shop/huile-de-coupe-et-percage/	2026-07-06 16:41:37.512816+02	2026-07-07 02:33:20.167969+02
132	huile-filtre-a-air-hautes-performances-750-ml	Huile filtre à air hautes performances 750ml – GS27	MO110252	\N	1249	EUR	L’Huile Filtre à Air Hautes Performances GS27® Moto permet de garantir le bon fonctionnement du moteur. Afin de visualiser lors de l’application, l’huile est colorée bleue.	Description\nL’Huile Filtre à Air Hautes Performances GS27® Moto permet de garantir le bon fonctionnement du moteur. Afin de visualiser lors de l’application, l’huile est colorée bleue.	[]	en_stock	https://pieces-auto.fr/shop/huile-filtre-a-air-hautes-performances-750-ml/	2026-07-06 16:41:37.526009+02	2026-07-07 02:33:24.242114+02
133	huile-xtc-10w40-semi-synthese-a3-b4-12	Huile XTC 10w40 semi synthèse a3/b4-12 – Bardahl	36243	\N	2890	EUR	L'huile XTC 10w40 semi synthèse a3/b4-12 Bardahl, Semi-synthèse - Essence et Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile semi- synthétique, hautes performances, pour moteur essence et diesel, turbo- compressés ou non.\nPour des intervalles de vidange prolongés.\nExcellente protection lors de la mise en température et aux différents régimes du moteur.\nLa XTC 10W40 BARDAHL s’utilise en toutes saisons.\nBonne fluidité à basse température.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtc-10w40-semi-synthese-a3-b4-12/	2026-07-06 16:41:37.539074+02	2026-07-07 02:33:28.369346+02
134	huile-xtc-10w60-100-synthesea3-b4-12	Huile XTC 10w60 100 % synthésea3/b4-12 – Bardahl	36253	\N	6103	EUR	L'huile XTC 10w60 100 % synthésea3/b4-12 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile 100% synthèse, hautes performances, pour tous moteurs essence, LPG et diesel, turbo-compressés ou non. Pour des intervalles d’entretien prolongés. Excellente protection lors de la mise en température et aux différents régimes du moteur. La XTS 10W60 XTS BARDAHL s’utilise en toutes saisons. Viscosité adaptée à basse et haute température.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtc-10w60-100-synthesea3-b4-12/	2026-07-06 16:41:37.550533+02	2026-07-07 02:33:32.208065+02
183	nettoyant-carburateur-aerosol	Nettoyant carburateur aérosol – Bardahl	1115	\N	2045	EUR	Le nettoyant carburateur aerosol Bardahl, stabilise le ralenti et nettoye intérieur et extérieur	Description\nNettoie parfaitement l’intérieur et l’extérieur du carburateur.\nDissout et élimine tout type de dépôt.\nStabilise le ralenti et supprime les trous à l’accélération.\nRétablit la nervosité, la puissance et l’accélération.\nEvite la surconsommation de carburant et les émissions polluantes.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-carburateur-aerosol/	2026-07-06 16:41:37.998754+02	2026-07-07 02:36:47.54621+02
136	huile-xtec-0w30-100-synthese-c2-12-psa-b71-2312	Huile XTEC 0w30 100 % synthèse c2-12 psa b71-2312 – Bardahl	36523	\N	4990	EUR	L'huile XTEC 0w30 100 % synthèse c2-12 psa b71-2312 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile de synthèse haute performance à faible teneur en cendres, conçue pour prolonger la durée de vie et conserver l’efficacité des systèmes de réduction d’émission pour les voitures diesel et essence. La XTEC 0W30 BARDAHL peut être utilisée pour tous les moteurs Diesel et essence conformes à la norme PSA B71 2312	[]	en_stock	https://pieces-auto.fr/shop/huile-xtec-0w30-100-synthese-c2-12-psa-b71-2312/	2026-07-06 16:41:37.565372+02	2026-07-07 02:33:40.461621+02
137	huile-xtec-5w30-100-synthese-c2-2	Huile XTEC 5w30 100 % synthèse c2 – Bardahl	36533	\N	4390	EUR	L'huile XTEC 5w30 100 % synthèse c2 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile de synthèse « Fuel economy » formulée à partir d’additifs de dernière génération, et spécialement étudiée pour les véhicules équipéS d’un filtre à particules (FAP), répondant aux normes de dépollution EURO IV et EURO V. La XTEC 5W30 C2 BARDAHL est une huile moteur LOW SAPS (à faible teneur en cendres), hautes performances, à faible viscosité, spécialement conçue pour réduire la consommation de carburant et les émissions de CO2.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtec-5w30-100-synthese-c2-2/	2026-07-06 16:41:37.57193+02	2026-07-07 02:33:44.512934+02
138	huile-xtec-5w30-100-synthese-c3	Huile XTEC 5w30 100 % synthèse c3 – Bardahl	36303	\N	4590	EUR	L'huile XTEC 5w30 100 % synthèse c3 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile de synthèse à teneur en cendres réduite (Low Saps), “Fuel economy”, formulée à partir d’additifs de dernière génération, et spécialement étudiée pour les véhicules équipés d’un filtre à particules (FAP), répondant aux normes de dépollution EURO IV et EURO V. La XTEC 5W30 C3 BARDAHL dispose d’un HTHS élevé, garantissant une excellente protection. Particulièrement recommandée pour les dernières générations de BMW, MERCEDES, PORSCHE, VW, AUDI, SEAT, SKODA, moteurs essence ou diesel pour lesquels un niveau ACEA C3 est requis.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtec-5w30-100-synthese-c3/	2026-07-06 16:41:37.577743+02	2026-07-07 02:33:48.359519+02
139	huile-xtec-5w30-100-synthese-c4	Huile XTEC 5w30 100 % synthèse c4 – Bardahl	36153	\N	4590	EUR	L'huile XTEC 5w30 100 % synthèse c4 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile de synthèse à faible teneur en cendre (Low Saps) et “Fuel economy” formulée à partir d’additifs de dernière génération, et spécialement étudiée pour les véhicules équipées d’un filtre à particules (FAP), répondant aux normes de dépollution EURO IV et EURO V. Contient des additifs de performance adaptés aux convertisseurs catalytiques de dernière génération. Particulièrement recommandée pour la spécification RENAULT RN720. Cette huile moteur est appropriée pour les moteurs essence et diesel, avec ous sans turbo, des voitures de tourisme et camionnettes.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtec-5w30-100-synthese-c4/	2026-07-06 16:41:37.583279+02	2026-07-07 02:33:52.430464+02
140	huile-xtec-5w40-100-synthese-c3	Huile XTEC 5w40 100 % synthèse c3 – Bardahl	36343	\N	3950	EUR	L'huile XTEC 5w40 100 % synthèse c3 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile de synthèse à teneur en cendre réduite Mid Saps, “Fuel economy” formulée à partir d’additifs de dernière génération, et spécialement étudiée pour les véhicules équipés d’un filtre à particules (FAP), répondant aux normes de dépollution EURO IV et EURO V. La XTEC 5W40 BARDAHL dispose d’un Haut HTHS garantissant une excellente protection. Convient aux moteurs essence et diesel, avec ou sans turbo, des voitures et camionnettes.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtec-5w40-100-synthese-c3/	2026-07-06 16:41:37.590484+02	2026-07-07 02:33:56.296238+02
141	huile-xtm-15w40-minerale-a3-b3	Huile XTM 15w40 minérale a3/b3 – Bardahl	36263	\N	3394	EUR	L'huile XTM 15w40 minéraL'a3/b3 Bardahl, Minérale - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile minérale pour véhicules de tourisme et utilitaires. Idéal pour les parcs mixtes. Moteurs essence et diesel, GPL, équipés ou non de turbo ou de catalyseur. La XTM 15W40 BARDAHL a un excellent pouvoir détergent et une très bonne protection contre l’usure	[]	en_stock	https://pieces-auto.fr/shop/huile-xtm-15w40-minerale-a3-b3/	2026-07-06 16:41:37.598919+02	2026-07-07 02:34:00.396702+02
142	huile-xtm-15w50-minerale-2	Huile XTM 15w50 minérale – Bardahl	36353	\N	3746	EUR	L'huile XTM 15w50 minérale Bardahl, Minérale - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile minérale pour véhicules de tourisme et utilitaires. Idéal pour les parcs mixtes. Moteurs essence et diesel, GPL, équipés ou non de turbo ou de catalyseur. La XTM 15W50 BARDAHL offre une très bonne protection contre l’usure grace aux stabilisateurs de viscosité. Très bon pouvoir détergent, anti-rouille et anti-corrosion.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtm-15w50-minerale-2/	2026-07-06 16:41:37.604348+02	2026-07-07 02:34:04.199327+02
143	huile-xtm-15w50-minerale	Huile XTM 15w50 minérale – Bardahl	36351	\N	979	EUR	L'huile XTM 15w50 minérale Bardahl, Minérale - Essence & Diesel,est une huile à haut pouvoir lubrifiant	Description\nHuile minérale pour véhicules de tourisme et utilitaires. Idéal pour les parcs mixtes. Moteurs essence et diesel, GPL, équipés ou non de turbo ou de catalyseur. La XTM 15W50 BARDAHL offre une très bonne protection contre l’usure grace aux stabilisateurs de viscosité. Très bon pouvoir détergent, anti-rouille et anti-corrosion.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtm-15w50-minerale/	2026-07-06 16:41:37.610171+02	2026-07-07 02:34:08.264319+02
144	huile-xts-0w20-100-synthese-essence-hybride-gf-5	Huile XTS 0w20 100 % synthèse Essence & hybride gf-5 – Bardahl	36333	\N	4891	EUR	L'huile XTS 0w20 100 % synthèse Essence & hybride gf-5 Bardahl, 100% Synthétique - Essence & Hybride,est une huile à haut pouvoir lubrifiant	Description\nHuile nouvelle génération, 100% synthèse, élaborée pour une propreté optimale du moteur. La XTS 0W20 BARDAHL est compatible avec le carburant E85, évite la surconsommation, améliore la propreté des pistons, réduit les émissions, protège contre l’usure et les boues.	[]	en_stock	https://pieces-auto.fr/shop/huile-xts-0w20-100-synthese-essence-hybride-gf-5/	2026-07-06 16:41:37.616188+02	2026-07-07 02:34:12.095724+02
146	huile-xts-0w40-100-synthese-a3-b4-12	Huile XTS 0w40 100 % synthèse a3/b4-12 – Bardahl	36143	\N	6071	EUR	L'huile XTS 0w40 100 % synthèse a3/b4-12 Bardahl, 100% Synthéque - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile 100% synthèse, à base d’additifs de performance de dernière génération. Réduit la friction, élimine les boues, et optimise la consommation de carburant. Protection générale assurée. La XTS 0W40 BARDAHL a une excellente résistance aux cisaillements. Elle est adaptée aux véhicules essence et diesel, de forte cylindrée, injection directe ou indirecte, avec ou sans turbo.	[]	en_stock	https://pieces-auto.fr/shop/huile-xts-0w40-100-synthese-a3-b4-12/	2026-07-06 16:41:37.638468+02	2026-07-07 02:34:20.401234+02
147	huile-xts-5w30-100-synthese-a1-b1-a5-b5	Huile XTS 5w30 100 % synthèse a1/b1 a5/b5 – Bardahl	36543	\N	4836	EUR	L'huile XTS 5w30 100 % synthèse a1/b1 a5/b5 Bardahl, 100% Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile 100% synthèse, à base d’additifs de performance de dernière génération, permettant de réduire la friction, éliminant les boues, et optimisant la consommation de carburant. Protection générale assurée. La XTS 5W30 BARDAHL est spécialement formulée pour une lubrification optimale des moteurs Essence et Diesel FORD de dernière génération.	[]	en_stock	https://pieces-auto.fr/shop/huile-xts-5w30-100-synthese-a1-b1-a5-b5/	2026-07-06 16:41:37.650334+02	2026-07-07 02:34:24.451964+02
148	hyperlubrifiant	Hyperlubrifiant – Bardahl	1300	\N	3545	EUR	L'hyperlubrifiant Bardahl est un puissant additif permettant d'envelopper toutes les surfaces métaliques d'un fim d'huile indéteriorable ! C'est une protection longue durée assurée	Description\nRéduit les fictions et évite l’usure du moteurAméliore souplesse, reprises et accélérationsFacilite le démarrage à froid et réduit les bruits moteurEvite les surconsommation d’huile et de carburantLimite les émissions polluantes et facilite le passage au contrôle technique anti-pollutionProlonge la durée de vie du moteurIdéal pour les véhicules équipés de la technologie « Start & stop »	[]	en_stock	https://pieces-auto.fr/shop/hyperlubrifiant/	2026-07-06 16:41:37.663626+02	2026-07-07 02:34:28.312065+02
149	impermeabilisant-anti-tache-textiles-cuirs	Imperméabilisant anti-tâches textiles & cuirs – GS27	MO110132	\N	1050	EUR	L'Imperméabilisant Anti-Tache GS27® est conçu pour imperméabiliser et protéger contre les taches tous les cuirs et textiles. Il est parfait pour les vestes, les gants, les chaussures ainsi que les bagages. En déposant une barrière protectrice sur les tissus et cuirs, il empêche l’huile et les autres taches de pénétrer la matière. Sa texture est non grasse, non collante et non glissante.	Description\nL’Imperméabilisant Anti-Tache GS27® est conçu pour imperméabiliser et protéger contre les taches tous les cuirs et textiles. Il est parfait pour les vestes, les gants, les chaussures ainsi que les bagages. En déposant une barrière protectrice sur les tissus et cuirs, il empêche l’huile et les autres taches de pénétrer la matière. Sa texture est non grasse, non collante et non glissante.	[]	en_stock	https://pieces-auto.fr/shop/impermeabilisant-anti-tache-textiles-cuirs/	2026-07-06 16:41:37.676547+02	2026-07-07 02:34:32.38311+02
150	impermeabilisant-anti-tache-textiles	Imperméabilisant anti-taches textiles – GS27	CL110281	\N	1490	EUR	L'Imperméabilisant Anti-Tache GS27® est conçu pour imperméabiliser et protéger contre les taches tous les cuirs et textiles. Il est parfait pour les vestes, les gants, les chaussures ainsi que les bagages. En déposant une barrière protectrice sur les tissus et cuirs, il empêche l’huile et les autres taches de pénétrer la matière. Sa texture est non grasse, non collante et non glissante	Description\nL’Imperméabilisant Anti-Tache GS27® est conçu pour imperméabiliser et protéger contre les taches tous les cuirs et textiles. Il est parfait pour les vestes, les gants, les chaussures ainsi que les bagages. En déposant une barrière protectrice sur les tissus et cuirs, il empêche l’huile et les autres taches de pénétrer la matière. Sa texture est non grasse, non collante et non glissante	[]	en_stock	https://pieces-auto.fr/shop/impermeabilisant-anti-tache-textiles/	2026-07-06 16:41:37.688755+02	2026-07-07 02:34:36.178764+02
151	iso-100-viscosite-moyenne	Iso 100 viscosite moyenne – Bardahl	4376	\N	3810	EUR	Le Iso 100 viscosite moyenne Bardahl permet une lubrification optimale et une protection renforcée tout en réduisant l'usure.	Description\nHuile synthétique miscible tout gaz réfrigérent HFC – HFCF. Viscosité élevée. Protection maximum contre l’usure et le blocage du compresseur. Réduit le niveau de bruit. De qualité hygroscopique, absorbe l’humidité de l’air. Compatible avec tous les composants des climatisations automobiles.	[]	en_stock	https://pieces-auto.fr/shop/iso-100-viscosite-moyenne/	2026-07-06 16:41:37.702374+02	2026-07-07 02:34:40.352274+02
152	iso-150-viscosite-elevee	Iso 150 viscosité élevée – Bardahl	4386	\N	3664	EUR	Le Iso 150 viscosite elevee Bardahl permet une lubrification optimale et une protection renforcée tout en réduisant l'usure.	Description\nHuile synthétique miscible tout gaz réfrigérant HFC – HFCF. Protection maximum contre l’usure et le blocage du compresseur. Résiste à la corrosion, à l’humidité, à l’oxydation. Réduit le niveau de bruit. Assure la propreté de l’évaporateur, ne contient pas de cire ou résine.	[]	en_stock	https://pieces-auto.fr/shop/iso-150-viscosite-elevee/	2026-07-06 16:41:37.711691+02	2026-07-07 02:34:44.142683+02
153	iso-46-viscosite-basse	Iso 46 viscosite basse – Bardahl	4375	\N	3599	EUR	Le Iso 46 viscosite basse Bardahl permet une lubrification optimale et une protection renforcée tout en réduisant l'usure.	Description\nProtection maximum contre l’usure et le blocage du compresseur – Réduit le niveau de bruit – Assure la propreté de l’évaporateur, ne contient pas de cire ou résine – Compatible avec tous les composants des climatisations automobiles.	[]	en_stock	https://pieces-auto.fr/shop/iso-46-viscosite-basse/	2026-07-06 16:41:37.72102+02	2026-07-07 02:34:48.266307+02
154	joint-silicone-bleu	Joint silicone bleu – Bardahl	5002	\N	1396	EUR	Le joint silicone bleu Bardahl est compatible tous type de carter et joints. Il sèche rapidement et est utilisable de -60 °c à +250 °c	Description\nJoint d’étanchéitésilicone bleu conçupour remplacer lesjoints prédécoupés.Conserve sa souplesseà haute et bassetempérature.Résiste à l’eau, l’huileet aux liquides derefroidissement.S’utilise sur le métal,verre, bois et sur laplupart des plastiques.Egalise les surfaces.	[]	en_stock	https://pieces-auto.fr/shop/joint-silicone-bleu/	2026-07-06 16:41:37.729917+02	2026-07-07 02:34:52.062786+02
156	kit-de-distribution	Kit de distribution	\N	\N	0	EUR	KIT COMPLET : PIÈCES DE QUALITÉ PREMIÈRE MONTE PARFAITEMENT ADAPTÉES   Courroie(s) de distribution  Galet(s) tendeur(s)  Galet(s) enrouleur(s)  Autres éléments nécessaires pour garantir une révision complète (boulons, ressorts, etc.)  Instructions d’installation (spécifiques)  Autocollant de kilométrage   Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nMIEUX VAUT PRÉVENIR QUE GUÉRIR\nLe meilleur moyen de garantir à vos clients un système de transmission par courroie de distribution fiable est de changer simultanément les courroies de distribution, les galets enrouleurs et les galets tendeurs.\nChaque kit\ncontient tous les composants appropriés, ainsi que les instructions d’installation. Chaque composant du kit est par ailleurs garanti de qualité équivalente à la première monte.\nCes composants de qualité supérieure sont capables de résister durablement à de telles sollicitations\nUn mauvais fonctionnement du système de transmission peut provoquer de sérieuses difficultés, car la détérioration d’un des composants de la distribution peut engendrer des dégâts sur l’ensemble du système.	[]	en_stock	https://pieces-auto.fr/shop/kit-de-distribution/	2026-07-06 16:41:37.749268+02	2026-07-06 16:41:37.749268+02
160	kit-machoires-de-frein	Kit mâchoires de frein	\N	\N	0	EUR	Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nSécurité Totale\nLes freins à tambour sont développés pour répondre aux besoins de tous les types de véhicules qu’ils équipent. La parfaite interaction entre les différents composants des freins à tambour Bosch leur offre de nombreux avantages :\nFiabilité accrue\nConstance au freinage\nMontage facile et précis\nGrande longévité	[]	en_stock	https://pieces-auto.fr/shop/kit-machoires-de-frein/	2026-07-06 16:41:37.808332+02	2026-07-06 16:41:37.808332+02
158	kit-econettoyage-moteur	Kit Eco nettoyage moteur – Bardahl	9345	\N	3190	EUR	Le Kit econettoyage moteur Bardahl permet de nettoyer et protéger l'ensemble du système d'injection, de décrasser FAP et Turbo sans démontage	Description\nNettoie et protège l’ensemble du système d’injection (injecteurs, soupapes, pompes, chambre de combustion, …)\nDécrasse sans démontage FAP et turbo\nStoppe les fumées et réduit la consommation\nRestaure les performances du moteur\nFacilite le passage au contrôle technique anti pollution	[]	en_stock	https://pieces-auto.fr/shop/kit-econettoyage-moteur/	2026-07-06 16:41:37.766656+02	2026-07-07 02:35:08.556665+02
161	kit-nettoyant-vannes-egr	Kit nettoyant vannes EGR – Bardahl	9123	\N	4590	EUR	Le kit nettoyant vannes EGR Bardahl, elimine les dépôts, stabilise le ralenti et baisse la consommation.	Description\nEliminent gommes, vernis, suies et dépôts (résidus charbonneux) des soupapes et de la vanne EGR. Nettoient le système d’admission, les soupapes et la vanne EGR. Rétablissent la circulation d’air vers les chambres de combustion et éliminent les trous à l’accélération. Assurent une combustion parfaite. Réduisent la consommation. Préviennent la formation des dépôts. Compatibles FAP et pots catalytiques.	[]	en_stock	https://pieces-auto.fr/shop/kit-nettoyant-vannes-egr/	2026-07-06 16:41:37.827364+02	2026-07-07 02:35:20.406424+02
162	kit-soin-renovation-cuir	Kit soin & rénovation cuir – GS27	CL160230	\N	3390	EUR	Le Kit Soin & Rénovation Cuir GS27® est composé de tous les produits nécessaires à un soin complet de vos cuirs.  Il comprend : -un lait nettoyant au pH neutre qui permet de nettoyer en profondeur des cuirs mêmes délicats sans les dessécher. -une crème nourrissante enrichie en cire de carnauba qui permet de nourrir et assouplir le cuir. Elle redonne aux cuirs leur aspect d’origine en rénovant les cuirs desséchés et craquelés. La formule du Soin & Rénovation Cuir GS27® est non grasse, elle respecte les porosités du cuir et ne laisse pas d'effet gras au toucher après utilisation. Avec ce traitement, les cuirs garderont leur souplesse et leur couleur d'origine. Les cuirs étant nourris et protégés, ils garderont un aspect neuf plus longtemps. Application : - sur tous les types de cuir sauf peaux retournées (alcantara®, daim, nubuck) et agneau plongé. - Sur tous les couleurs de cuir. Utilisation possible pour : ameublement, gants, chaussures, blousons, maroquinerie, etc.	Description\nLe Kit Soin & Rénovation Cuir GS27® est composé de tous les produits nécessaires à un soin complet de vos cuirs.\nIl comprend :\n-un lait nettoyant au pH neutre qui permet de nettoyer en profondeur des cuirs mêmes délicats sans les dessécher.\n-une crème nourrissante enrichie en cire de carnauba qui permet de nourrir et assouplir le cuir. Elle redonne aux cuirs leur aspect d’origine en rénovant les cuirs desséchés et craquelés. La formule du Soin & Rénovation Cuir GS27® est non grasse, elle respecte les porosités du cuir et ne laisse pas d’effet gras au toucher après utilisation.\nAvec ce traitement, les cuirs garderont leur souplesse et leur couleur d’origine. Les cuirs étant nourris et protégés, ils garderont un aspect neuf plus longtemps.\nApplication :\n– sur tous les types de cuir sauf peaux retournées (alcantara®, daim, nubuck) et agneau plongé.\n– Sur tous les couleurs de cuir.\nUtilisation possible pour : ameublement, gants, chaussures, blousons, maroquinerie, etc.	[]	en_stock	https://pieces-auto.fr/shop/kit-soin-renovation-cuir/	2026-07-06 16:41:37.838287+02	2026-07-07 02:35:24.448549+02
226	poussoirs-hydrauliques	Poussoirs hydrauliques – Bardahl	1022	\N	3145	EUR	Le poussoirs hydrauliques Bardahl, réduit bruits et usure elimine les dépôts longue durée.	Description\nRétablit le bon fonctionnement des poussoirs hydrauliques. Dissout et élimine les impuretés et les dépôts de gomme. Ne bouche pas les filtres à huile. Contient des agents extrême pression. Pour tout type d’huile et tout type de motorisation. Compatible tout type d’huile et de motorisation.	[]	en_stock	https://pieces-auto.fr/shop/poussoirs-hydrauliques/	2026-07-06 16:41:38.409371+02	2026-07-07 02:39:40.428992+02
164	lingettes-desinfectantes-gs27	Lingettes désinfectantes – GS27	CL180440	\N	999	EUR	Élimine 99,99% des bactéries.  Lingettes désinfectantes, conçues pour nettoyer et purifer efficacement l'habitable de votre véhicule.	Description\nNettoie & désinfecte tout l’habitacle de votre voiture.\nUtilisable sur toutes les surfaces intérieures du véhicule.\nElimine 99.9% des bactéries, champignons et virus.*\nEfficaces contre les virus H1N1 et herpès simplex selon la norme EN 14476+A1.\n*Testé selon la norme EN 1276 et EN 1650.\nLingettes non grasses. Testées dermatologiquement.\nPour une première utilisation, nous vous recommandons de faire un essai au préalable sur une partie discrète du véhicule afin d’observer le résultat obtenu.	[]	en_stock	https://pieces-auto.fr/shop/lingettes-desinfectantes-gs27/	2026-07-06 16:41:37.859564+02	2026-07-07 02:35:32.409122+02
165	lingettes-entretien-cuir	Lingettes entretien cuir – GS27	CL180410	\N	890	EUR	Pour un entretien rapide et facile de tous les cuirs au quotidien, utilisez les Lingettes Cuir GS27 Classics®. Elles permettent de nettoyer et d’entretenir le cuir, tout en prévenant son usure.	Description\nPour un entretien rapide et facile de tous les cuirs au quotidien, utilisez les Lingettes Cuir GS27 Classics®.\nElles permettent de nettoyer et d’entretenir le cuir, tout en prévenant son usure.	[]	en_stock	https://pieces-auto.fr/shop/lingettes-entretien-cuir/	2026-07-06 16:41:37.868675+02	2026-07-07 02:35:36.19163+02
166	lingettes-plastiques-satines-citron-orange	Lingettes plastiques satinées citron/orange – GS27	CL180420	\N	890	EUR	Les Lingettes Plastiques GS27 Classics® permettent de nettoyer et dépoussiérer toutes les surfaces plastiques. Sa formule non grasse va déposer un film de protection antistatique qui va limiter l’incrustation des impuretés. Les Lingettes Plastiques GS27 Classics® vont raviver la couleur des plastiques tout en laissant un aspect satiné.	Description\nLes Lingettes Plastiques GS27 Classics® permettent de nettoyer et dépoussiérer toutes les surfaces plastiques.\nSa formule non grasse va déposer un film de protection antistatique qui va limiter l’incrustation des impuretés. Les Lingettes Plastiques GS27 Classics® vont raviver la couleur des plastiques tout en laissant un aspect satiné.	[]	en_stock	https://pieces-auto.fr/shop/lingettes-plastiques-satines-citron-orange/	2026-07-06 16:41:37.878163+02	2026-07-07 02:35:40.330167+02
167	lingettes-vitres	Lingettes vitres – GS27	CL180430	\N	890	EUR	Les Lingettes Vitres GS27 Classics® permettent de nettoyer facilement toutes les surfaces vitrées. Elles assurent une finition parfaite et améliorent la visibilité. Elles s’utilisent à l’intérieur comme à l’extérieur du véhicule. A l'intérieur du véhicule, elles enlèvent le film gras et limitent l'apparition de la buée. A l'extérieur, elles éliminent les insectes et toutes les salissures diverses. Pour nettoyer votre pare-brise à tout moment, rangez-les dans la boite à gants.	Description\nLes Lingettes Vitres GS27 Classics® permettent de nettoyer facilement toutes les surfaces vitrées. Elles assurent une finition parfaite et améliorent la visibilité. Elles s’utilisent à l’intérieur comme à l’extérieur du véhicule. A l’intérieur du véhicule, elles enlèvent le film gras et limitent l’apparition de la buée. A l’extérieur, elles éliminent les insectes et toutes les salissures diverses. Pour nettoyer votre pare-brise à tout moment, rangez-les dans la boite à gants.	[]	en_stock	https://pieces-auto.fr/shop/lingettes-vitres/	2026-07-06 16:41:37.886306+02	2026-07-07 02:35:44.078382+02
168	liquide-de-refroidissement-vw-type-d-g12-g12	Liquide de refroidissement vw type d g12/g12+ – Bardahl	8313	\N	1217	EUR	Le Liquide de refroidissement vw type d g12/g12+ Bardahl, est un liquide de refroidissement rose  de type D avec des proriétés Anti-corrosion & Anti-surchauffe	\N	[]	en_stock	https://pieces-auto.fr/shop/liquide-de-refroidissement-vw-type-d-g12-g12/	2026-07-06 16:41:37.894683+02	2026-07-07 02:35:47.980408+02
169	lubrifiant-portes-fenetres-volets	Lubrifiant portes, fenêtres, volets – Bardahl	44611	\N	790	EUR	Le Lubrifiant portes, fenetres, volets Bardahl est non salissant, Anti-friction, et réduit les bruits.	Description\nLubrifie et protège gonds, poignées, serrures, rails, mécanismes glissières, charnières, baies coulissantes, placards, stores… Utilisation intérieur et extérieur sur PVC, aluminium, acier etc… Protège de la rouille. Ne coule pas. Incolore.	[]	en_stock	https://pieces-auto.fr/shop/lubrifiant-portes-fenetres-volets/	2026-07-06 16:41:37.902876+02	2026-07-07 02:35:52.324095+02
170	lubrifiant-serrure	Lubrifiant spécial serrure – Bardahl	44601	\N	890	EUR	Le Lubrifiant serrure Bardahl est une formulation non grasse qui assure une propretée de vos sérrures - Formulation sèche permet de débloquer immédiatement pour une action longue durée.	Description\nLubrifie-dégrippe et débloque immédiatement serrures, barillets, verrous, paumelles, cadenas, crémones etc… Chasse l’humidité et protège de l’usure. Libère les pièces soudées par la saleté et l’oxydation et prévient la formation du givre. Formule unique, à haut pouvoir de pénétration, non grasse, n’attire pas la poussière.	[]	en_stock	https://pieces-auto.fr/shop/lubrifiant-serrure/	2026-07-06 16:41:37.911167+02	2026-07-07 02:35:56.377616+02
171	lubrifiant-silicone	Lubrifiant silicone – Bardahl	44672	\N	890	EUR	Le Lubrifiant silicone Bardahl est un lubrifiant sec et anti-corrosion. Il reste propre et diminue les bruits.	Description\nAnti-adhérent. Résiste à l’humidité. Supprime les bruits. Protège le caoutchouc et le plastique du gel en hiver et du dessèchement en été. Pour tout type de support.	[]	en_stock	https://pieces-auto.fr/shop/lubrifiant-silicone/	2026-07-06 16:41:37.917164+02	2026-07-07 02:36:00.444596+02
172	lustreur-brille-express-2	Lustreur brille express – Bardahl	38914	\N	1295	EUR	Le Lustreur brillant express Bardahl est facile et rapide d'utilisation. De plus il donne un brillant instantané et de longue durée	Description\nTrès simple et rapide d’utilisation.\nApporte une couche de brillance extrême et de protection.\nProtection lonigue durée.\nToutes peintures.	[]	en_stock	https://pieces-auto.fr/shop/lustreur-brille-express-2/	2026-07-06 16:41:37.923817+02	2026-07-07 02:36:04.012232+02
173	lustreur-brille-express	Lustreur brille express – Bardhal	38916	\N	1195	EUR	Le Lustreur brille express Bardahl, Nettoie et détache les petites taches et contamination du véhicule	Description\nElimine les taches et salissures\nRavive les couleurs des tissus\nConvient pour tissus, moquettes…	[]	en_stock	https://pieces-auto.fr/shop/lustreur-brille-express/	2026-07-06 16:41:37.9309+02	2026-07-07 02:36:08.014038+02
175	lustreur-express	Lustreur express – GS27	CL120162	\N	1390	EUR	Nettoyez et lustrez votre véhicule en toute simplicité avec le Lustreur Express GS27 Classics®.  Facile d’utilisation, le Lustreur Express GS27® agit très rapidement et il ne nécessite pas de rinçage à l'eau. Grâce à sa formule innovante les saletés s'enlèvent avec une simple microfibre laissant la carrosserie propre et brillante.	Description\nNettoyez et lustrez votre véhicule en toute simplicité avec le Lustreur Express GS27 Classics®.\nFacile d’utilisation, le Lustreur Express GS27® agit très rapidement et il ne nécessite pas de rinçage à l’eau. Grâce à sa formule innovante les saletés s’enlèvent avec une simple microfibre laissant la carrosserie propre et brillante.	[]	en_stock	https://pieces-auto.fr/shop/lustreur-express/	2026-07-06 16:41:37.944467+02	2026-07-07 02:36:15.908269+02
176	lustreur-performance	Lustreur performance – GS27	CL140211	\N	1790	EUR	Le Lustreur Performance GS27 Classics® permet d’apporter brillance et éclat à la peinture de votre carrosserie. Ce produit est facile à appliquer et sans effort notamment grâce à sa texture crémeuse.	Description\nLe Lustreur Performance GS27 Classics® permet d’apporter brillance et éclat à la peinture de votre carrosserie. Ce produit est facile à appliquer et sans effort notamment grâce à sa texture crémeuse.	[]	en_stock	https://pieces-auto.fr/shop/lustreur-performance/	2026-07-06 16:41:37.950839+02	2026-07-07 02:36:19.838878+02
177	promo-degivrant-300-100-ml-offerts-holts	Lot de 3 dégivrants 300ml + 100ml OFFERTS – Holts	HOL208181-1	\N	1215	EUR	Lot de 3 Dégivrant HOLTS 300ml + 100 ml GRATUITS Dégivre efficacement les surfaces vitrées jusqu’à -25°C. Limite la réapparition du givre, sans trace. Pulvérisation large et rapidité d’action	Description\nLot de 3\nDégivrant HOLTS 300ml + 100 ml GRATUITS Dégivre efficacement les surfaces vitrées jusqu’à -25°C. Limite la réapparition du givre, sans trace. Pulvérisation large et rapidité d’action	[]	en_stock	https://pieces-auto.fr/shop/promo-degivrant-300-100-ml-offerts-holts/	2026-07-06 16:41:37.957341+02	2026-07-07 02:36:24.000792+02
178	lustreur-platine	Lustreur platine – GS27	CL140221	\N	2490	EUR	Le Lustreur Platine GS27 Classics®, est un produit enrichi en cire de carnauba qui permet de redonner éclat et brillance intense à votre véhicule. L’utilisation de ce produit est idéale pour protéger efficacement les peintures anciennes et préserver l'éclat des peintures neuves.	Description\nLe Lustreur Platine GS27 Classics®, est un produit enrichi en cire de carnauba qui permet de redonner éclat et brillance intense à votre véhicule. L’utilisation de ce produit est idéale pour protéger efficacement les peintures anciennes et préserver l’éclat des peintures neuves.	[]	en_stock	https://pieces-auto.fr/shop/lustreur-platine/	2026-07-06 16:41:37.963605+02	2026-07-07 02:36:27.676348+02
179	mastic-echappement-magasin	Mastic échappement magasin – Bardahl	4469	\N	1250	EUR	Le mastic echappement Bardahl, est conçu pour resister aux hautes températures afin de conserver l'etanchéité de votre montage. Il est durable et facilite le montage.	Description\nAssure une étanchéité parfaite des raccords des systèmes d’échappement. Facilite le montage et le démontage. Résiste aux températures élevées et aux vibrations. Diminue les bruits d’échappement. Compatible tout système d’échappement.	[]	en_stock	https://pieces-auto.fr/shop/mastic-echappement-magasin/	2026-07-06 16:41:37.969894+02	2026-07-07 02:36:31.658384+02
180	maxi-compression	Maxi compression – Bardahl	1030	\N	4390	EUR	Le maxi compression Bardahl augmente la nervosité, la puissance et la reprise.	Description\nRétablit et rééquilibre les compressions. Stoppe les fuites d’huile en redonnant de l’élasticité aux joints. Diminue la consommation d’huile. Réduit les bruits du moteur. Améliore la puissance et les performances. Tous types d’huiles et tous types de motorisations.	[]	en_stock	https://pieces-auto.fr/shop/maxi-compression/	2026-07-06 16:41:37.977391+02	2026-07-07 02:36:35.72866+02
181	microfibre-double-face	Microfibre double face – GS27	OU180180	\N	1590	EUR	Dotée de deux faces permettant une multiplicité d’utilisations, la microfibre Double Face GS27® s’utilise aussi bien pour l’habitacle que pour la carrosserie. La partie noire est optimale pour : - Dépoussiérer son habitacle. - Essuyer sa carrosserie. - Frotter avec un shampoing. La partie verte est faite pour : - Nettoyer les vitres. - Appliquer un lustreur. - Nettoyer l’intérieur du véhicule.	Description\nDotée de deux faces permettant une multiplicité d’utilisations, la microfibre Double Face GS27® s’utilise aussi bien pour l’habitacle que pour la carrosserie.\nLa partie noire est optimale pour :\n– Dépoussiérer son habitacle.\n– Essuyer sa carrosserie.\n– Frotter avec un shampoing.\nLa partie verte est faite pour :\n– Nettoyer les vitres.\n– Appliquer un lustreur.\n– Nettoyer l’intérieur du véhicule.	[]	en_stock	https://pieces-auto.fr/shop/microfibre-double-face/	2026-07-06 16:41:37.984155+02	2026-07-07 02:36:39.407235+02
185	nettoyant-injecteurs-diesel	Nettoyant injecteurs Diesel – Bardahl	1155	\N	3250	EUR	Le nettoyant injecteurs Diesel Bardahl, synonyme de performance, economie et anti-pollution.	Description\nNettoie les injecteurs, la chambre de combustion, soupapes, pompe à injection et canalisations. Rétablit les performances du moteur. Réduit les bruits moteur à froid (claquement). Supprime les fumées noires à l’échappement. Facilite le démarrage à froid. Réduit les consommations excessives de carburant. Evite les coûts de réparations (changement de pièces). Aide à la mise en conformité de votre véhicule aux nouvelles normes anti- pollution (contrôle technique et code de la route).	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-injecteurs-diesel/	2026-07-06 16:41:38.012953+02	2026-07-07 02:36:55.679489+02
186	nettoyant-injecteurs-essence-copie	Nettoyant injecteurs Essence – Bardahl	T1198	\N	3290	EUR	Le nettoyant injecteurs Essence Bardahl, décrasse votre moteur pour retrouver une performance optimale tout en faisant des economie et en réduisant la pollution.	Description\nNettoie et protège l’ensemble du système d’injection. Baisse la consommation de carburant . Empêche le grippage des injecteurs et pompes. Réduit les bruits et l’usure moteur. Réduit les fumées et les gaz d’échappement et facilite le passage au contrôle technique. Compatible tout type de motorisation . Miscible dans tout type d’essence.\nTraitement à effectuer tous les 5 000 km et avant le contrôle technique anti- pollution.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-injecteurs-essence-copie/	2026-07-06 16:41:38.019107+02	2026-07-07 02:36:59.514643+02
187	nettoyant-injecteurs-essence	Nettoyant injecteurs Essence – Bardahl	1198	\N	3290	EUR	Le nettoyant injecteurs Essence Bardahl, décrasse votre moteur pour retrouver une performance optimale tout en faisant des economie et en réduisant la pollution.	Description\nNettoie et protège l’ensemble du système d’injection. Baisse la consommation de carburant . Empêche le grippage des injecteurs et pompes. Réduit les bruits et l’usure moteur. Réduit les fumées et les gaz d’échappement et facilite le passage au contrôle technique. Compatible tout type de motorisation . Miscible dans tout type d’essence.\nTraitement à effectuer tous les 5 000 km et avant le contrôle technique anti- pollution.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-injecteurs-essence/	2026-07-06 16:41:38.027749+02	2026-07-07 02:37:03.781052+02
188	nettoyant-injecteurs-pro-diesel-nouvelle-formule-hp	Nettoyant injecteurs pro Diesel- nouvelle formule hp – Bardahl	11551	\N	4246	EUR	Le Nettoyant injecteurs pro Diesel nouvelle formule Bardahl offre une action ultra nettoyante et immédiate	Description\nNettoie et protège l’ensemble du système d’injection (injecteurs, pompe, soupapes, chambre à combustion)\nRétablit le débit des injetceurs\nSupprime trous à l’accélération et ralenti instable\nRestaure les performances d’origine du moteur(nervosité, puissance consommation)\nBaisse la consommation de carburant\nEmpêche le grippage des injecteurs et de la pompe\nRéduit les bruits moteurs grâce à ses qualités lubrifiantes.\nRéduit les fumées noires à l’échappement et facilite le passage au contrôle technique anti pollution.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-injecteurs-pro-diesel-nouvelle-formule-hp/	2026-07-06 16:41:38.034383+02	2026-07-07 02:37:07.795615+02
189	nettoyant-injecteurs-pro-essence-nouvelle-formule-hp	Nettoyant injecteurs pro Essence – nouvelle formule hp – Bardahl	11981	\N	4246	EUR	Le Nettoyant injecteurs pro Essence nouvelle formule Bardahl offre une action ultra nettoyante et immédiate	Description\nNettoie et protège l’ensemble du système d’injection (injecteurs, pompe, soupapes, chambre à combustion)\nRétablit le débit des injetceurs\nSupprime trous à l’accélération et ralenti instable\nRestaure les performances d’origine du moteur(nervosité, puissance consommation)\nBaisse la consommation de carburant\nEmpêche le grippage des injecteurs et de la pompe\nRéduit les bruits moteurs grâce à ses qualités lubrifiantes.\nRéduit les fumées noires à l’échappement et facilite le passage a contrôle technique anti pollution.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-injecteurs-pro-essence-nouvelle-formule-hp/	2026-07-06 16:41:38.040569+02	2026-07-07 02:37:11.930237+02
191	nettoyant-jantes-gel-titanium	Nettoyant jantes gel titanium – GS27	CL120132	\N	1590	EUR	Le Nettoyant Jantes Gel Titanium® GS27 Classics® adhère intégralement aux jantes et permet d’assurer un nettoyage en profondeur. Sa formule est unique et elle associe le Titanium® (composant léger et très résistant utilisé dans des secteurs de pointe comme l'aéronautique et la Formule 1) à une formulation en gel composée de tensio-actifs. Ce produit permet de nettoyer les poussières de frein et graisses incrustées en procurant un brillant intense et en laissant un film protecteur sur vos jantes. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Nettoyant Jantes Gel Titanium® GS27 Classics® adhère intégralement aux jantes et permet d’assurer un nettoyage en profondeur. Sa formule est unique et elle associe le Titanium® (composant léger et très résistant utilisé dans des secteurs de pointe comme l’aéronautique et la Formule 1) à une formulation en gel composée de tensio-actifs. Ce produit permet de nettoyer les poussières de frein et graisses incrustées en procurant un brillant intense et en laissant un film protecteur sur vos jantes.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-jantes-gel-titanium/	2026-07-06 16:41:38.062821+02	2026-07-07 02:37:19.83551+02
193	nettoyant-jantes-peintes-vernies	Nettoyant jantes peintes/vernies – Bardahl	38919	\N	1096	EUR	Le Nettoyant jantes peintes et vernies Bardahl, Décrasse et protège vos jantes pour une action longue durée	Description\nNettoie sans effort\nDécrasse en profondeur\nRavive la brillance d’origine	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-jantes-peintes-vernies/	2026-07-06 16:41:38.078689+02	2026-07-07 02:37:27.689488+02
194	nettoyant-jantes-sans-acide	Nettoyant jantes sans acide – GS27	CL120112	\N	1090	EUR	Le Nettoyant Jantes Sans Acide GS27 Classics® permet de nettoyer facilement les résidus de plaquettes de frein et les graisses déposés sur vos jantes ou enjoliveurs plastiques. Sa formule est renforcée afin d’agir rapidement. Elle va protéger les jantes et ralentir leur encrassement. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Nettoyant Jantes Sans Acide GS27 Classics® permet de nettoyer facilement les résidus de plaquettes de frein et les graisses déposés sur vos jantes ou enjoliveurs plastiques. Sa formule est renforcée afin  d’agir rapidement. Elle va protéger les jantes et ralentir leur encrassement. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-jantes-sans-acide/	2026-07-06 16:41:38.084569+02	2026-07-07 02:37:31.418866+02
195	nettoyant-previdange	Nettoyant prévidange – Bardahl	1032	\N	2645	EUR	Le nettoyant previdange Bardahl, nettoie le circuit d'huile evite surchauffe et usure lubrification optimale.	Description\nDissout les boues et les particules et les maintient en suspension. Rend l’intérieur de votre moteur propre. Réduit la pollution. Prolonge la durée de vie du moteur en permettant une lubrification optimale. Pout tout type d’huile et tout type de motorisation.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-previdange/	2026-07-06 16:41:38.090707+02	2026-07-07 02:37:35.557399+02
197	nettoyant-radiateur	Nettoyant radiateur Tous moteurs – Bardahl	1096	\N	2446	EUR	Le nettoyant radiateur Bardahl, elimine les dépôts, est anti-surchauffe et détartrant.	Description\nElimine tous les dépôts nuisibles comme la rouille, la tartre, la boue. Résiste à la pression et aux températures élevées des moteurs modernes. Empêche la surchauffe du moteur.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-radiateur/	2026-07-06 16:41:38.109199+02	2026-07-07 02:37:43.599707+02
198	nettoyant-resine-taille-haie-jardin	Nettoyant résine taille-haie jardin – Bardahl	4440	\N	1183	EUR	Le nettoyant resine taille haie jardin Bardahl, a une action immédiate et dissout les résidus tout en nettoyant et protégeant votre matériel.	Description\nDissout, nettoie et décolle les résiduts de résine, d’huile, de goudron ou de colle sur les accessoires de coupe. Prolonge la durée de vie. Ne laisse pas de traces. N’attaque pas les peintures et vernis.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-resine-taille-haie-jardin/	2026-07-06 16:41:38.117413+02	2026-07-07 02:37:47.962943+02
199	nettoyant-tissus	Nettoyant tissus – GS27	CL110123	\N	1190	EUR	Doté d’une formulation mousse active aux propriétés antistatiques, le Nettoyant Tissus GS27 Classics® nettoie et ravive les tissus, moquettes et tapis de votre voiture. Il permet aussi de traiter les fibres, d’absorber les saletés et de raviver les couleurs. Après avoir séché, le nettoyant tissus GS27® laisse un conglomérat de salissures très sec, facilement éliminable avec un aspirateur. Dangereux - veillez à respecter les précautions d'emploi.	Description\nDoté d’une formulation mousse active aux propriétés antistatiques, le Nettoyant Tissus GS27 Classics® nettoie et ravive les tissus, moquettes et tapis de votre voiture. Il permet aussi de traiter les fibres, d’absorber les saletés et de raviver les couleurs.\nAprès avoir séché, le nettoyant tissus GS27® laisse un conglomérat de salissures très sec, facilement éliminable avec un aspirateur.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-tissus/	2026-07-06 16:41:38.125245+02	2026-07-07 02:37:52.055783+02
210	pack-nettoyant-et-purifiant-climatisation-2x125-ml	Pack nettoyant et purifiant climatisation 2 x 125 ml – Bardahl	9395	\N	2150	EUR	Le Purifiant habitacle Bardahl purifie l'atmosphère de l'habitacle et détruit les mauvaises odeurs tout en parfumant légèrement.  Le Désinfectant Climatisation Bardahl désinfecte en profondeur votre circuit d'air afin d'éliminer toutes bactéries, virus et champignons.	Description\nPurifiant habitacle\nPurifie l’atmosphère de l’habitacle\nSupprime les odeurs\nDétruit les odeurs due à la prolifération bactérienne\nElimine durablement acariens et bactéries\nParfume légèrement votre habitacle.\nDésinfectant Climatisation\nNettoie l’ensemble des composants du circuit technique (Conduit, échangeur, évaporateur etc…)​\nDésinfecte et purifie le circuit d’air\nSupprime les mauvaises odeurs\nProtège l’évaporateur et le radiateur de chauffage de la corrosion\nParfume légèrement l’habitacle\n1 flacon traite 1 véhicule​\n1 fois par an ou tous les 10 000 km	[]	en_stock	https://pieces-auto.fr/shop/pack-nettoyant-et-purifiant-climatisation-2x125-ml/	2026-07-06 16:41:38.215603+02	2026-07-07 02:38:36.499128+02
202	alternateur	Alternateur	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/alternateur/	2026-07-06 16:41:38.144261+02	2026-07-06 16:41:38.144261+02
203	bobine-dallumage	Bobine d’allumage	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/bobine-dallumage/	2026-07-06 16:41:38.150556+02	2026-07-06 16:41:38.150556+02
204	bougie-dallumage	Bougie d’allumage	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/bougie-dallumage/	2026-07-06 16:41:38.158019+02	2026-07-06 16:41:38.158019+02
223	poulie-damper	Poulie damper	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/poulie-damper/	2026-07-06 16:41:38.332353+02	2026-07-06 16:41:38.332353+02
224	silencieux	Silencieux	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/silencieux/	2026-07-06 16:41:38.341924+02	2026-07-06 16:41:38.341924+02
201	nettoyant-turbo-econettoyage-1l	Nettoyant Turbo Econettoyage 1L – Bardahl	4777	\N	8494	EUR	Le nettoyant Turbo Econettoyage 1L Bardahl, elimine suie et calamine de votre turbo et réduit le grippage pour retrouver toute la puissance moteur ! A utiliser en action curative & préventive.	Description\nElimine les suies et la calamine à l’origine du grippage de turbos à géométrie variable.\nDécrasse sans démontage: aubages mobiles, géométrie variable et ailettes turbo.\nréduit l’encrassement du turbo, de la vannes EGR, du FAP, de l’échappement et du pot catalytique.\nBaisse la consommation de carburant et les émissions polluantes.\nProlonge la durée de vie du turbo.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-turbo-econettoyage-1l/	2026-07-06 16:41:38.138603+02	2026-07-07 02:37:59.949842+02
205	nettoyant-vanne-egr-essence-diesel	Nettoyant vanne EGR Essence & Diesel – Bardahl	2314	\N	4645	EUR	Le nettoyant vanne EGR Essence & Diesel Bardahl s'utilise sans démontage	Description\nElimine gomme, vernis, suies et dépôts sur la vanne EGR\nRétablit la circulation d’air vers les chambres de combustion et élimine les trous à l’accélération\nAssure une combustion parfaite\nLimite la surconsommation de carburant, la perte de puissance et le remplacement de la vanne EGR\nPrévient la formation de dépôts\nProlonge la durée de vie et le bon fonctionnement de la vanne EGR	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-vanne-egr-essence-diesel/	2026-07-06 16:41:38.179788+02	2026-07-07 02:38:16.631464+02
206	nettoyant-vanne-egr-essence-et-diesel	Nettoyant vanne EGR Essence et Diesel – Bardahl	4328	\N	2390	EUR	Le nettoyant vanne EGR Essence et Diesel Bardahl, élimine les dépôts et stabilise le ralenti.	Description\nElimine gommes, vernis, suies et dépôts (résidus charbonneux) des soupapes et de la vanne EGR. Nettoie le système d’admission d’air, les soupapes et la vanne EGR (débitmètre). Rétablit la circulation d’air vers les chambres de combustion et élimine les trous à l’accélération. Assure une combustion parfaite. Réduit la consommation. Compatible FAP et pots catalytiques.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-vanne-egr-essence-et-diesel/	2026-07-06 16:41:38.190023+02	2026-07-07 02:38:20.522598+02
208	nettoyant-vitres	Nettoyant vitres – GS27	CL110181	\N	990	EUR	Avec sa mousse active aux propriétés antistatiques, le Nettoyant Vitres GS27 Classics® nettoie facilement toutes les vitres intérieures et extérieures et il dissout les films gras et secs. Il élimine également les résidus de climatisation, de chauffage et de fumée de cigarettes	Description\nAvec sa mousse active aux propriétés antistatiques, le Nettoyant Vitres GS27 Classics® nettoie facilement toutes les vitres intérieures et extérieures et il dissout les films gras et secs. Il élimine également les résidus de climatisation, de chauffage et de fumée de cigarettes	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-vitres/	2026-07-06 16:41:38.203514+02	2026-07-07 02:38:28.521632+02
209	octane-booster	Octane booster – Bardahl	2302	\N	2850	EUR	Le octane booster Bardahl augmente votre indice d'octane pour augmenter performance puissance et nervosité de votre véhicule essence	Description\nAugmente le couple, le régime et la puissance moteur jusqu’à 5 chevaux.Augmente le taux d’octane jusqu’à 5 points. Augmente le rendement moteur. Améliore la combustion et évite l’encrassement du moteur.\nUsage normal: 1 flacon traite 80 L d’essence. Usage sportif: 1 flacon traite 40 L d’essence. Tout type de motorisation. Recommandé par les plus grands constructeurs.\nNotez qu’une utilisation répétée peut nuire au bon fonctionnementdu pot catalytique dans certains cas.	[]	en_stock	https://pieces-auto.fr/shop/octane-booster/	2026-07-06 16:41:38.209861+02	2026-07-07 02:38:32.674756+02
214	demarreur	Démarreur	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/demarreur/	2026-07-06 16:41:38.252835+02	2026-07-06 16:41:38.252835+02
215	etrier-de-frein	Étrier de frein	\N	\N	0	EUR	Performance en toutes conditions  Les étriers de frein assurent un freinage fiable en pressant les plaquettes contre les disques. Conçus en matériaux durables et résistants, ils garantissent une excellente performance et une longue durée de vie. Faciles à installer, ils sont compatibles avec de nombreux véhicules pour un freinage sûr et efficace.  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nLes étriers de frein sont des composants essentiels du système de freinage, garantissant la sécurité et le confort de conduite. Ils assurent la bonne pression des plaquettes de frein contre le disque, permettant un arrêt efficace et rapide du véhicule.\nNos étriers de frein sont conçus avec des matériaux robustes et résistants à la corrosion, offrant une durabilité maximale même dans des conditions extrêmes. Grâce à leur précision et à leur fiabilité, ils assurent une réponse rapide et un freinage performant pour tous types de véhicules.	[]	en_stock	https://pieces-auto.fr/shop/etrier-de-frein/	2026-07-06 16:41:38.268715+02	2026-07-06 16:41:38.268715+02
216	faisceau-dallumage	Faisceau d’allumage	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/faisceau-dallumage/	2026-07-06 16:41:38.27782+02	2026-07-06 16:41:38.27782+02
217	plaquettes-de-frein	Plaquettes de frein	\N	\N	0	EUR	Performance en toutes conditions  Que ce soit lors de conditions humides ou d’extrêmes températures, la distance de freinage doit être la plus courte possible. Les plaquettes de frein Bosch grâce à l’excellente stabilité de leur matériau de friction répondent à ces conditions extrêmes.  Faire le choix des plaquettes de frein de qualité garantie d'origine vous garanti à la fois un confort supérieur avec une réduction des bruits et des vibrations au freinage, et une sécurité maximale grâce à leur résistance extrême à l’usure.  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	Description\nUne précision irréprochable\nÀ chaque freinage du véhicule, les plaquettes et disques de frein doivent supporter des forces extrêmes en une fraction de seconde.\nLes véhicules d’aujourd’hui ont des systèmes de frein qui développent une puissance instantanée largement supérieure à la puissance du moteur. À cette fin, nos plaquettes de frein vous garantissent une efficacité et une sécurité sans compromis à chaque instant.	[]	en_stock	https://pieces-auto.fr/shop/plaquettes-de-frein/	2026-07-06 16:41:38.285171+02	2026-07-06 16:41:38.285171+02
218	pneu-4x4	Pneu 4×4	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/pneu-4x4/	2026-07-06 16:41:38.291633+02	2026-07-06 16:41:38.291633+02
219	pneu-tourisme	Pneu Tourisme	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/pneu-tourisme/	2026-07-06 16:41:38.298058+02	2026-07-06 16:41:38.298058+02
222	pompe-a-eau	Pompe à eau	\N	\N	0	EUR	Performance en toutes conditions  Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/pompe-a-eau/	2026-07-06 16:41:38.316279+02	2026-07-06 16:41:38.316279+02
212	pate-a-reparer-special-metal-epoxy	Pâte à réparer spécial métal epoxy – Bardahl	49917	\N	1290	EUR	Le Pate à reparer special metal epoxy Bardahl est spécialement conçue pour les réparations express du métal. Une fois malaxé, ce baton bi-composant passera d'un état mou à un état aussi solide que du métal après quelques minutes	Description\nBâtonnet époxy modelable. Devient résistant comme du métal. Se ponce, se taraude , se peint , … Efficacede +50°C à +180°C, supporte ponctuellement jusqu’à 300°C. Résiste à l’eau, l’essence; l’huile et à la corrosion. Comble des fissures jusqu’à 15mm.	[]	en_stock	https://pieces-auto.fr/shop/pate-a-reparer-special-metal-epoxy/	2026-07-06 16:41:38.229899+02	2026-07-07 02:38:44.705101+02
213	pate-a-reparer-universelle-epoxy	Pâte à réparer universelle epoxy – Bardahl	49919	\N	1290	EUR	Le Pate a reparer universelle epoxy Bardahl, Une fois malaxé, ce baton bi-composant passera d'un état mou à un état aussi solide que du métal après quelques minutes	Description\nBâtonnet époxy modelable idéal pour colmater les fuites et réparer les trous, les fissures, … Devient résistant comme le métal.\nSe ponde, se perce, se taraude, se peint. Adhère sur tous types de surface, même humide (sous l’eau). Efficace de -50°C à +180°C, supporte ponctuellement jusquà 300°C.\nRésiste à l’eau, l’essence, l’huile et à la corrosion. Comble les fissure jusqu’à 15mm.	[]	en_stock	https://pieces-auto.fr/shop/pate-a-reparer-universelle-epoxy/	2026-07-06 16:41:38.236293+02	2026-07-07 02:38:48.547737+02
220	polish-micro-rayures	Polish micro rayures – GS27	CL140201	\N	1790	EUR	Le Polish Micro-Rayures GS27 Classics® permet d’éliminer facilement et sans risque les micro-rayures et les autres défauts (tourbillons, taches, etc.) présents sur votre carrosserie grâce à sa technologie micro-abrasive.	Description\nLe Polish Micro-Rayures GS27 Classics® permet d’éliminer facilement et sans risque les micro-rayures et les autres défauts (tourbillons, taches, etc.) présents sur votre carrosserie grâce à sa technologie micro-abrasive.	[]	en_stock	https://pieces-auto.fr/shop/polish-micro-rayures/	2026-07-06 16:41:38.304377+02	2026-07-07 02:39:16.415879+02
221	polish-renovateur-micro-rayures	Polish rénovateur micro rayures – Bardahl	38913	\N	1613	EUR	Le Polish renovateur micro rayures Bardahl redonne un éclat de neuf sur votre véhicule. Grâce à sa formulation, il permet de supprimer les rayures et micro griffes.	Description\nDésoxyde la surface de la peinture\nElimine les mico-rayures\nRedonne la brillance d’origine\nProtection longue durée	[]	en_stock	https://pieces-auto.fr/shop/polish-renovateur-micro-rayures/	2026-07-06 16:41:38.310057+02	2026-07-07 02:39:20.521284+02
228	rapide-glue-cyanoacrylate	Rapide glue cyanoacrylate – Bardahl	49905	\N	1550	EUR	Le Rapide glue cyanoacrylate Bardahl, est une colle extraforte monocomposant. Cette colle multi-usage viendra à bout de toutes vos petites réparation et est compatible tous matériaux.	Description\nColle cyanoacrylate, incolore, instantanée, super puissante. Résiste à l’eau, aux chocs, aux vibrations et aux écarts de températures entre -50°C et +80°C.	[]	en_stock	https://pieces-auto.fr/shop/rapide-glue-cyanoacrylate/	2026-07-06 16:41:38.438677+02	2026-07-07 02:39:48.305033+02
230	renovateur-chromes	Rénovateur chromes – GS27	CL150102	\N	990	EUR	Le Rénovateur Alu & Chromes GS27® permet grâce à sa formule abrasive de désoxyder, polir rapidement et de manière efficace tous les métaux. Il dépose un film protecteur tout en redonnant de la brillance aux surfaces ternies pour un résultat durable. Ce Rénovateur Alu & Chromes GS27® peut être utilisé sur tous les chromes, l'inox, l'aluminium, le cuivre, le bronze, l'étain, l'argent.	Description\nLe Rénovateur Alu & Chromes GS27® permet grâce à sa formule abrasive de désoxyder, polir rapidement et de manière efficace tous les métaux. Il dépose un film protecteur tout en redonnant de la brillance aux surfaces ternies pour un résultat durable. Ce Rénovateur Alu & Chromes GS27® peut être utilisé sur tous les chromes, l’inox, l’aluminium, le cuivre, le bronze, l’étain, l’argent.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-chromes/	2026-07-06 16:41:38.465491+02	2026-07-07 02:39:56.801469+02
231	renovateur-pare-chocs	Rénovateur pare-chocs – GS27	CL110111	\N	1390	EUR	Le Rénovateur Pare-Chocs GS27 Classics® ravive les pare-chocs, bandes de protection latérales ou toute autre finition extérieure en plastique non peint. La couleur des surfaces ternies par le temps est ravivée. Il dépose une mince pellicule satinée et protectrice après utilisation. Compatible avec toutes les teintes de pare-chocs et de plastiques. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Rénovateur Pare-Chocs GS27 Classics® ravive les pare-chocs, bandes de protection latérales ou toute autre finition extérieure en plastique non peint.\nLa couleur des surfaces ternies par le temps est ravivée.\nIl dépose une mince pellicule satinée et protectrice après utilisation.\nCompatible avec toutes les teintes de pare-chocs et de plastiques.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-pare-chocs/	2026-07-06 16:41:38.478958+02	2026-07-07 02:40:00.815125+02
232	renovateur-peintures	Rénovateur peintures – GS27	CL140102	\N	1690	EUR	Le Rénovateur Peintures GS27 Classics®enlève le voile terne accumulé au fil du temps en désoxydant en profondeur la carrosserie de votre véhicule. Il redonne à votre carrosserie sa brillance d'origine. Nous vous conseillons de terminer par l'application du Lustreur Titanium+® GS27 Classics® pour encore plus de brillance et de protection.	Description\nLe Rénovateur Peintures GS27 Classics®enlève le voile terne accumulé au fil du temps en désoxydant en profondeur la carrosserie de votre véhicule. Il redonne à votre carrosserie sa brillance d’origine.\nNous vous conseillons de terminer par l’application du Lustreur Titanium+® GS27 Classics® pour encore plus de brillance et de protection.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-peintures/	2026-07-06 16:41:38.492134+02	2026-07-07 02:40:04.862327+02
233	renovateur-plastiques-brillant-pomme-verte	Rénovateur plastiques brillant pomme verte – GS27	CL110191	\N	1290	EUR	Vos plastiques intérieurs sont ternis par le temps et la lumière ? Le Rénovateur Plastiques Brillants GS27 Classics® va permettre de rénover et raviver tous vos plastiques intérieurs en déposant un film antistatique protecteur et non gras et brillant. Son plus ? Son agréable parfum pomme verte. Finition brillante. Dangereux – veillez à respecter les précautions d'emploi.	Description\nVos plastiques intérieurs sont ternis par le temps et la lumière ? Le Rénovateur Plastiques Brillants GS27 Classics® va permettre de rénover et raviver tous vos plastiques intérieurs en déposant un film antistatique protecteur et non gras et brillant. Son plus ? Son agréable parfum pomme verte. Finition brillante. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-plastiques-brillant-pomme-verte/	2026-07-06 16:41:38.503965+02	2026-07-07 02:40:08.646449+02
234	renovateur-plastiques-mat-voiture-neuve	Rénovateur plastiques mat voiture neuve – GS27	CL110153	\N	890	EUR	Vos plastiques intérieurs sont ternis par le temps et la lumière ? Le Rénovateur Plastiques Mats GS27 Classics® va permettre de rénover et raviver tous vos plastiques intérieurs en déposant un film antistatique protecteur et non gras. Son plus ? Son agréable parfum voiture neuve. Finition mate. Dangereux – veillez à respecter les précautions d'emploi.	Description\nVos plastiques intérieurs sont ternis par le temps et la lumière ? Le Rénovateur Plastiques Mats GS27 Classics® va permettre de rénover et raviver tous vos plastiques intérieurs en déposant un film antistatique protecteur et non gras. Son plus ? Son agréable parfum voiture neuve. Finition mate. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-plastiques-mat-voiture-neuve/	2026-07-06 16:41:38.51218+02	2026-07-07 02:40:12.736752+02
235	renovateur-plastiques-satine-citron-orange	Rénovateur plastiques finition satinée Parfum citron/orange – GS27	CL110142	\N	1290	EUR	Le Rénovateur Plastiques Satinés GS27 Classics® permet de rénover et raviver tous les plastiques intérieurs qui ont été ternis par le temps et la lumière. Il dépose un film antistatique protecteur et non gras. Agréable à utiliser grâce à son parfum citron/orange. Finition satinée. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Rénovateur Plastiques Satinés GS27 Classics® permet de rénover et raviver tous les plastiques intérieurs qui ont été ternis par le temps et la lumière. Il dépose un film antistatique protecteur et non gras. Agréable à utiliser grâce à son parfum citron/orange. Finition satinée. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-plastiques-satine-citron-orange/	2026-07-06 16:41:38.519074+02	2026-07-07 02:40:16.59879+02
240	sangles-dechappement	Sangles d’échappement	PLLSANGLES	\N	0	EUR	Toutes nos pièces techniques sont disponibles uniquement en magasin.  Trouver votre magasin PIECES AUTO  Demander un devis	\N	[]	en_stock	https://pieces-auto.fr/shop/sangles-dechappement/	2026-07-06 16:41:38.559607+02	2026-07-06 16:41:38.559607+02
237	repare-crevaison	Répare crevaison – Bardahl	4940	\N	1350	EUR	Le repare crevaison Bardahl, répare et regonfle votre pneu. Il a une action immédiate et ne nécessite pas de démontage.	Description\nRépare et regonfle immédiatement votre pneu sans outils et sans démontage. Compatible tout type de pneu avec ou sans chambre à air (tubeless).	[]	en_stock	https://pieces-auto.fr/shop/repare-crevaison/	2026-07-06 16:41:38.530575+02	2026-07-07 02:40:24.681091+02
238	repare-crevaison-express-300-ml	Répare crevaison express 300 ml – GS27	MO110221	\N	790	EUR	Le Répare Crevaison Express GS27® Moto permet de réparer et de regonfler de manière instantanée les pneus crevés d’une moto. Il est pratique, facile et rapide à utiliser.	Description\nLe Répare Crevaison Express GS27® Moto permet de réparer et de regonfler de manière instantanée les pneus crevés d’une moto. Il est pratique, facile et rapide à utiliser.	[]	en_stock	https://pieces-auto.fr/shop/repare-crevaison-express-300-ml/	2026-07-06 16:41:38.536916+02	2026-07-07 02:40:28.748995+02
241	savon-creme-microbilles-parfum-orange	Savon crème microbilles Parfum orange – Bardahl	4434V	\N	2190	EUR	Le savon crème Micro billes Bardahl a été développé pour tous les bricoleurs et professionnels. Grâce à ses propriétés micro abrasives et hydratantes, aucune tâche ne résistera !	Description\n#N/A	[]	en_stock	https://pieces-auto.fr/shop/savon-creme-microbilles-parfum-orange/	2026-07-06 16:41:38.56627+02	2026-07-07 02:40:40.54601+02
242	shampoing-concentre-bardahl	Shampoing lustrant peintures & plastiques – Bardahl	38915	\N	1195	EUR	Le Shampoing concentré Bardahl dégraisse votre véhicule et décontamine la carrosserie de tous les polluants et goudrons. Il a un effet brillant immédiat et n'est pas agressif pour la peau	Description\nNettoie\nRénove\nFait briller	[]	en_stock	https://pieces-auto.fr/shop/shampoing-concentre-bardahl/	2026-07-06 16:41:38.581525+02	2026-07-07 02:40:45.030376+02
244	shampooing-pomme-535ml-nouvelle-formule	Shampooing pomme 535ml – Nouvelle formule – GS27	CL130103	\N	1163	EUR	Le Shampooing Autolustrant GS27 Classics® permet d’enlever aisément toutes les microparticules de graisses et de salissures incrustées sur votre véhicule. Ce shampoing GS27® nettoie de manière efficace « le film routier » qui forme un voile terne et gras sur la carrosserie. Il assure un rendu brillant à votre voiture et il prolonge l'effet déperlant obtenu par l'application d'un lustreur GS27 Classics®. Son plus ? Son parfum pomme verte. Dangereux - respecter les précautions d'emploi.	Description\nLe Shampooing Autolustrant GS27 Classics® permet d’enlever aisément toutes les microparticules de graisses et de salissures incrustées sur votre véhicule. Ce shampoing GS27® nettoie de manière efficace « le film routier » qui forme un voile terne et gras sur la carrosserie. Il assure un rendu brillant à votre voiture et il prolonge l’effet déperlant obtenu par l’application d’un lustreur GS27 Classics®.\nSon plus ? Son parfum pomme verte.\nDangereux – respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/shampooing-pomme-535ml-nouvelle-formule/	2026-07-06 16:41:38.608151+02	2026-07-07 02:40:53.266549+02
245	shampooing-titanium-535ml-nouvelle-formule	Shampooing titanium 535ml – Nouvelle formule – GS27	CL130133	\N	1450	EUR	Le Shampooing Titanium® GS27 Classics® est un produit innovant, bénéficiant de la technologie Titanium® qui est un composant léger et résistant utilisé dans l'industrie de pointe comme l'aéronautique. Cette formule unique allie brillance et protection. Il permet de nettoyer en profondeur la carrosserie, en éliminant les salissures et le « film routier » à l'origine du voile gras et terne sur les véhicules. Grâce aux microparticules de Titanium® votre carrosserie sera brillante et protégée. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Shampooing Titanium® GS27 Classics® est un produit innovant, bénéficiant de la technologie Titanium® qui est un composant léger et résistant utilisé dans l’industrie de pointe comme l’aéronautique. Cette formule unique allie brillance et protection. Il permet de nettoyer en profondeur la carrosserie, en éliminant les salissures et le « film routier » à l’origine du voile gras et terne sur les véhicules. Grâce aux microparticules de Titanium® votre carrosserie sera brillante et protégée.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/shampooing-titanium-535ml-nouvelle-formule/	2026-07-06 16:41:38.619806+02	2026-07-07 02:40:57.307067+02
247	soin-du-cuir-ecocert	Soin du cuir Écocert – GS27	EC140121	\N	1150	EUR	Le Soin du Cuir – Ecocert GS27® Pure permet de : -nettoyer, entretenir, nourrir et redonner la souplesse aux cuirs.	Description\nLe Soin du Cuir – Ecocert GS27® Pure permet de :\n-nettoyer, entretenir, nourrir et redonner la souplesse aux cuirs.	[]	en_stock	https://pieces-auto.fr/shop/soin-du-cuir-ecocert/	2026-07-06 16:41:38.642896+02	2026-07-07 02:41:05.113716+02
248	stabilisateur-essence-24-mois	Stabilisateur Essence  24 mois – Bardahl	4874	\N	1750	EUR	Le stabilisateur Essence Bardahl permet de conserver votre carburant 24 mois	Description\nEvite de vidanger le réservoir lors de l’hivernage.\nProlonge la durée de conservation de l’essence 24 mois.Evite le colmatage des filtres à carburant.Brûle complètement sans laisser de dépôts.N’altère pas la qualité de l’essence.Assure une lubrification optimale des soupapes et sièges.	[]	en_stock	https://pieces-auto.fr/shop/stabilisateur-essence-24-mois/	2026-07-06 16:41:38.653631+02	2026-07-07 02:41:09.266972+02
249	stop-fuite-radiateur	Stop fuite radiateur – Bardahl	1099	\N	2345	EUR	Le stop fuite radiateur Bardahl, action immédiate, sans démontage et longue durée.	Description\nStoppe et prévient sans démontage les fuites du circuit de refroidissement. Protège de la formation de rouiile, tartre et corrosion. N’attaque pas les durits, les joints et les métaux. Assure une parfaite circulation des liquides et évite la surchauffe du moteur. Résiste aux pressions, aux vibrations et aux températures élevées.	[]	en_stock	https://pieces-auto.fr/shop/stop-fuite-radiateur/	2026-07-06 16:41:38.665213+02	2026-07-07 02:41:13.046591+02
250	huile-xtc-5w40-synthese-a3-b4-12	Huile XTC 5w40 synthèse  a3/b4-12	36163	\N	3890	EUR	L'huile XTC 5w40 synthèse a3/b4-12 Bardahl, Synthétique - Essence & Diesel, est une huile à haut pouvoir lubrifiant	Description\nHuile semi-synthétique, hautes performances, pour moteurs essence et diesel (AM 2000 et suivant). Convient aux moteurs turbo-compressés, multisoupapes et à injection directe. La XTC 5W40 BARDAHL s’utilise en toutes saisons et satisfait aux conditions les plus difficiles. Convient aux véhicules équipés d’un pot catalytique.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtc-5w40-synthese-a3-b4-12/	2026-07-06 16:41:38.676502+02	2026-07-07 02:41:17.126689+02
251	stop-fuite-boite-de-vitesse-manuelle	Stop-fuite boite de vitesse manuelle – Bardahl	1756	\N	2550	EUR	Le stop-fuite boite de vitesse manuelle Bardahl, régénère l'huile, colmate les fuites et a une action longue durée.	Description\nRestitue les propriétés d’origine des joints toriques internes et externes. Nettoie les gorges dans lesquelles sont logées les joints. Restaure les performances de l’huile par l’addition d’additifs neufs; prolonge la durée de vie des organes mécaniques. Ne reconditionne pas les joints fissurés ou cassés, n’agit pas sur les joints papier.	[]	en_stock	https://pieces-auto.fr/shop/stop-fuite-boite-de-vitesse-manuelle/	2026-07-06 16:41:38.68646+02	2026-07-07 02:41:21.192048+02
252	stop-fuite-direction-assistee	Stop fuite direction assistée – Bardahl	1755	\N	4045	EUR	Le stop-fuite direction assistee Bardahl, réduit les tremblements de votre direction, colmate les fuites, et régénère l'huile.	Description\nRestitue les propriétés d’origine des joints toriques. Restaure les performances de l’huile par l’addition d’additifs neufs et prolonge ainsi la durée de vie des organes mécaniques. Ne reconditionne pas les joints fissurés ou cassés, n’agit pas sur les joints papier. Compatible avec toutes les huiles utilisées dans les circuits de direction assistée ou dans les boîtes de vitesses automatiques répondant aux spécifications DEXRON ou équivalentes LHM.	[]	en_stock	https://pieces-auto.fr/shop/stop-fuite-direction-assistee/	2026-07-06 16:41:38.696825+02	2026-07-07 02:41:24.975451+02
253	stop-fuite-moteur	Stop fuite moteur – Bardhal	1107	\N	2545	EUR	Le stop-fuite moteur Bardahl, action rapide en colmatant les fuites pour un effet de longue durée	Description\nAugmente le volume des joints jusqu’à 70%. Assouplit les joints et les bagues durcis et rétrécis. Réduit les dépôts sur les soupapes. Diminue le bruit de l’arbre à cames et des culbuteurs. Tout type d’huile et tout type de motorisation.	[]	en_stock	https://pieces-auto.fr/shop/stop-fuite-moteur/	2026-07-06 16:41:38.705868+02	2026-07-07 02:41:29.003411+02
254	stop-fumee	Stop fumée – Bardahl	1020	\N	3190	EUR	Le stop fumée Bardahl, réduit la consommation, la pollution et les bruits.	Description\nRéduit l’émission des fumées à l’échappement. Réduit la consommation d’huile. Réduit les bruits. Tous types de motorisations et tous types d’huiles.	[]	en_stock	https://pieces-auto.fr/shop/stop-fumee/	2026-07-06 16:41:38.715472+02	2026-07-07 02:41:33.205681+02
255	substitut-de-plomb-traite-500-litres	Substitut de plomb – traite 500 litres – Bardahl	1151	\N	2845	EUR	Le substitut de plomb Bardahl, traite 250l ou 500l selon le dosage et pour une lubrification optimale.	Description\nPermet l’utilisation su SP95 et SP98 dans les moteurs 2 et 4 temps ancienne génération (fonctionnant au super plombé). Lubrifie et protège les soupapes et sièges. Brûle complètement sans laisser de dépôts. Prolonge la durée de vie du moteur.	[]	en_stock	https://pieces-auto.fr/shop/substitut-de-plomb-traite-500-litres/	2026-07-06 16:41:38.726597+02	2026-07-07 02:41:37.266443+02
256	tapis-caoutchouc-predecoupe-4-pieces	TAPIS CAOUTCHOUC PREDECOUPE X4PCS	SOD09720	\N	3350	EUR	Ce jeu est composé de 4 tapis en qualité NBR : ils sont composés de caoutchouc et de matières recyclées. Avant et Arrière - Caoutchouc - Universel.	Description\nCe jeu est composé de 4 tapis en qualité NBR : ils sont composés de caoutchouc et de matières recyclées.\nAvant et Arrière – Caoutchouc – Universel – Découpable\nCes tapis sont à la fois\nimperméables et résistants.\nCela permet également de donner une allure neuve à votre intérieur et un confort optimal, tout ça à petit prix.\nLa qualité NBR permet aux tapis de rester souples toute l’année\n: ils ne durcissent pas, ne se ramollissent pas et ne blanchissent pas. Ils sont lavables à l’eau. En plus, cette matière est naturellement antidérapante.\nIls peuvent également servir de sur-tapis pour l’automne et l’hiver.\nCes tapis sont compatibles avec une majorité de véhicules.\nTapis avant : 70x45cm.\nTapis arrière : 45x35cm.	[]	en_stock	https://pieces-auto.fr/shop/tapis-caoutchouc-predecoupe-4-pieces/	2026-07-06 16:41:38.737658+02	2026-07-07 02:41:41.366552+02
1	adaptateur-pour-prise-dattelage-13-vers-7-broches	Adaptateur pour prise d’attelage 13 vers 7 broches – Restagraf	17439	\N	1250	EUR	\N	\N	[]	en_stock	https://pieces-auto.fr/shop/adaptateur-pour-prise-dattelage-13-vers-7-broches/	2026-07-06 16:41:36.106722+02	2026-07-07 02:23:41.260946+02
4	baladeuse-led-250-50-lumens-articulee-rechargeable-stilker	Baladeuse LED 250 + 50 lumens articulée rechargeable – Stilker	SOD02162	\N	1990	EUR	Baladeuse LED compacte et articulée, ultra lumineuse, rechargeable, résistante aux chocs et avec crochet pivotant 360 degrés. Autonomie jusqu'à 8 heures. Idéale pour l'atelier ou le dépannage.	Description\nDécouvrez la baladeuse LED Stilker, un outil d’éclairage polyvalent, compact et ultra-lumineux, idéal pour les ateliers, garages, dépannages et travaux de précision. Grâce à sa LED COB puissante et à ses LED additionnelles, elle garantit une visibilité optimale dans toutes les situations. Sa conception en ABS léger et résistant aux chocs assure une durabilité remarquable, tandis que son articulation et ses fixations astucieuses facilitent le positionnement de la lumière exactement où vous en avez besoin.\nPoints forts :\nDouble éclairage\nAutonomie longue durée\nRechargeable +500 cycles, câble USB-C inclus\nTempérature lumière : 6500k (blanc froid, haute visibilité)\nInterrupteur on/off simple et accessible	[]	en_stock	https://pieces-auto.fr/shop/baladeuse-led-250-50-lumens-articulee-rechargeable-stilker/	2026-07-06 16:41:36.142094+02	2026-07-07 02:24:42.303499+02
9	cables-de-demarrage-en-cca-16mm²-2x25m-350a-pinces-isolees	Câbles de démarrage en CCA 16mm² 2×2,5m 350A pinces isolées – Sodise	SOD54360	\N	1550	EUR	Ces câbles de démarrage en CCA sont conçus pour garantir un démarrage rapide et fiable de votre véhicule, même dans les conditions les plus exigeantes.	Description\nCaractéristiques principales :\n– Section 16mm² : garantit une bonne conductivité pour un transfert efficace de courant.\n– Longueur totale 2x3m : suffisamment longs pour relier facilement deux véhicules, même dans des espaces réduits.\n– Courant nominal 350A : adapté à la plupart des véhicules particuliers et petits utilitaires.\n– Pinces isolées robustes : assurent une manipulation sûre en évitant tout risque de contact accidentel avec des parties métalliques.\n– Matériaux CCA (Copper-Clad Aluminium) : légère et résistante, cette technologie associe la conductivité du cuivre à la légèreté de l’aluminium.\n– Souplesse et durabilité : câbles flexibles qui résistent à l’usure et aux conditions extérieures.	[]	en_stock	https://pieces-auto.fr/shop/cables-de-demarrage-en-cca-16mm%c2%b2-2x25m-350a-pinces-isolees/	2026-07-06 16:41:36.1883+02	2026-07-07 02:25:03.314071+02
11	cables-de-demarrage-en-cca-35mm²-2x35m-620a-pinces-isolees	Câbles de démarrage en CCA 35mm² 2×3,5m 620A pinces isolées – Sodise	SOD54364	\N	4150	EUR	Ces câbles de démarrage en CCA (Copper-Clad Aluminium) de section 16mm², avec une longueur de 2x3,5 mètres et une capacité de 620A, sont conçus pour vous assurer un démarrage rapide et sécurisé de votre véhicule, même dans les situations les plus difficiles. Idéal pour garder dans votre véhicule, ce jeu de câbles de démarrage vous offre la puissance nécessaire pour un démarrage sûr et sans souci.	Description\nCaractéristiques principales :\n– Section 35mm² : garantit une bonne conductivité pour un transfert efficace de courant.\n– Longueur totale 2×3,5m : suffisamment longs pour relier facilement deux véhicules, même dans des espaces réduits.\n– Puissance élevée 650A : parfaite pour les véhicules lourds, utilitaires ou les situations nécessitant un courant important.\n– Pinces isolées robustes : assurent une manipulation sûre en évitant tout risque de contact accidentel avec des parties métalliques.\n– Matériaux CCA (Copper-Clad Aluminium) : légère et résistante, cette technologie associe la conductivité du cuivre à la légèreté de l’aluminium.\n– Souplesse et durabilité : câbles flexibles qui résistent à l’usure et aux conditions extérieures.	[]	en_stock	https://pieces-auto.fr/shop/cables-de-demarrage-en-cca-35mm%c2%b2-2x35m-620a-pinces-isolees/	2026-07-06 16:41:36.221453+02	2026-07-07 02:25:11.548051+02
70	brosse-jantes-flexi	brosse jantes flexi+ – GS27	OU180110	\N	1826	EUR	La brosse jantes Flexi + GS27® s’utilise avec un nettoyant jantes GS27 pour un résultat optimal. Elle permet d’entretenir n’importe quel type de jantes. Grace à ses poils souples, la brosse jantes Flexi + ne raye pas. Elle est flexible et résistante et elle atteint tous les recoins de vos jantes.	Description\nLa brosse jantes Flexi + GS27® s’utilise avec un nettoyant jantes GS27 pour un résultat optimal. Elle permet d’entretenir n’importe quel type de jantes. Grace à ses poils souples, la brosse jantes Flexi + ne raye pas. Elle est flexible et résistante et elle atteint tous les recoins de vos jantes.	[]	en_stock	https://pieces-auto.fr/shop/brosse-jantes-flexi/	2026-07-06 16:41:36.846676+02	2026-07-07 02:29:09.678994+02
258	traitement-diesel-traite-500-litres	Traitement Diesel 500L – Bardahl	1152	\N	2545	EUR	Le traitement Diesel Bardahl, evite la surconsommation et est anti-pollution.	Description\nPrévient l’encrassement et protège le système d’injection.Réduit la formation des dépôts de calamine et maintient propre le circuit d’alimentation.Réduit la surconsommation de carburant et l’émission de fumées noires.\nElimine l’eau contenue dans le carburant et stoppe cliquetis et auto-allumage.	[]	en_stock	https://pieces-auto.fr/shop/traitement-diesel-traite-500-litres/	2026-07-06 16:41:38.766692+02	2026-07-07 02:41:49.175687+02
259	traitement-essence	Traitement Essence – Bardhal	1149	\N	2545	EUR	Le traitement Essence Bardahl, evite la surconsommation et est un additif anti-pollution.	Description\nPrévient l’encrassement et protège le système d’injection.\nRéduit la formation des dépôts et calamine et maintient propre le circuit d’alimentation.\nRéduit la surconsommation de carburant et l’émission de fumées noires.\nElimine l’eau contenue dans le carburant et stoppe cliquetis et aut allumage.	[]	en_stock	https://pieces-auto.fr/shop/traitement-essence/	2026-07-06 16:41:38.785256+02	2026-07-07 02:41:53.658446+02
23	decrassant-5-en-1-moteur-diesel-1-l-300ml-offerts-bardahl	Décrassant 5 En 1 Moteur Diesel 1 L + 300ml Offerts – Bardahl	SAD9396-1	\N	6090	EUR	Le Décrassant moteur 5 en 1 de Bardahl permet de nettoyer votre moteur en ciblant précisément les organes les plus sensibles à l'encrassement. Sa formule se base sur un complexe d'additifs multifonctionnels issus de nos dernières recherches.  Les substances hautement concentrées qu’il contient utilisent votre carburant comme transporteur afin de nettoyer au mieux votre moteur. Il suffit donc de verser le Décrassant moteur 5 en 1 dans votre réservoir, et c’est votre carburant additivé qui sert de solution curative.	Description\nLe Décrassant moteur 5 en 1 (diesel) est le fruit de nos dernières recherches. Sa composition aux multiples propriétés lui permet d’agir sur chaque organe du moteur de manière efficace et sans danger.\nSimple et rapide d’utilisation.\nDécrasse sans démontage\n:\nle turbo, la vanne EGR, le filtre à particules, les soupapes d’échappement et le pot catalytique.\nNettoie et protège le système d’injection, et rétablit le débit des injecteurs.\nLimite les émissions polluantes et multiplie vos chances de réussite aux tests antipollution du contrôle technique.\nÉvite la surconsommation de carburant, la perte de puissance et le remplacement de pièces coûteuses.\nCompatible avec tous les véhicules hybrides	[]	en_stock	https://pieces-auto.fr/shop/decrassant-5-en-1-moteur-diesel-1-l-300ml-offerts-bardahl/	2026-07-06 16:41:36.318318+02	2026-07-07 02:25:59.945116+02
28	douilles-1-4-1-2-coffret-de-93-pieces-stilker	Douilles 1/4″ 1/2″ – Coffret de 93 pièces – Stilker	SOD67509-1	\N	6900	EUR	Composition : – 8 douilles longues 1/4″ : 6-7-8-9-10-11-12-13mm – 4 douilles longues 1/2″ : 14-15-17-19mm – 1 adaptateur 1/2″ pour embouts 8mm – 1 adaptateur pour douilles 1/4″ – 17 portes-embouts avec embout – 15 embouts 8mm – 13 … En savoir plus	Description\nComposition :\n– 8 douilles longues 1/4″ : 6-7-8-9-10-11-12-13mm\n– 4 douilles longues 1/2″ : 14-15-17-19mm\n– 1 adaptateur 1/2″ pour embouts 8mm\n– 1 adaptateur pour douilles 1/4″\n– 17 portes-embouts avec embout\n– 15 embouts 8mm\n– 13 douilles 1/4″ : 4-4,5-5-5,5-6-7-8-9-10-11-12-13-14mm\n– 18 douilles 1/2″ : 10-11-12-13-14-15-16-17-18-19-20-21-22-23-24-27-30-32mm\n– 1 cliquet 1/4″ réversible 45 dents\n– 1 cliquet 1/2″ réversible 45 dents\n– 1 rallonge coulissante 1/2″ 125mm\n– 1 douille à bougies 16\n– 1 douille à bougies 21\n– 1 cardan 1/4″\n– 1 cardan 1/2″\n– 1 barre coulissante 1/4″\n– 1 barre coulissante 1/2″\n– 1 tournevis porte-embouts 1/4″\n– 1 rallonge coulissante 1/4″ 100mm\n– 1 rallonge coulissante 1/4″ 50mm\n– 1 rallonge flexible 1/4″ 150mm\n– 3 clés hexagonales\nAcier chrome vanadium.	[]	en_stock	https://pieces-auto.fr/shop/douilles-1-4-1-2-coffret-de-93-pieces-stilker/	2026-07-06 16:41:36.359853+02	2026-07-07 02:26:20.209137+02
30	enrouleur-automatique-orientable-de-tuyau-dair-hybride-8-bar-8x12mm-201m-stilker	Enrouleur automatique orientable de tuyau d’air hybride 8 bar 8x12mm 20+1m – Stilker	SOD51322	\N	7900	EUR	Enrouleur automatique orientable 180° avec tuyau hybride extra souple 8 bar (8x12mm) de 20+1 mètres. Retour freiné "Slow motion" sécurisé, dispositif d’arrêt réglable et boule d’arrêt en fin de flexible. Idéal pour une utilisation flexible, sûre et durable.	Description\nDécouvrez notre enrouleur automatique orientable à 180°, pensé pour faciliter votre travail avec un tuyau d’air hybride 8 bar (8x12mm) de 20+1 mètres. Conçu pour allier souplesse et robustesse, ce tuyau hybride résiste efficacement aux variations de température tout en restant ultra flexible.\nLe support pivotant vous permet d’orienter l’enrouleur facilement sur 180°, offrant une liberté de mouvement optimale. Grâce au système de retour automatique par ressort avec freinage “Slow motion”, le déroulement et le retour du tuyau sont contrôlés, limitant les risques d’accidents et préservant votre matériel.\nLe dispositif d’arrêt à la longueur désirée vous garantit un positionnement précis du tuyau, tandis que la boule d’arrêt en fin de flexible évite tout dérapage ou retour intempestif.\nCe produit est la solution idéale pour les professionnels recherchant praticité, sécurité et durabilité dans leurs installations d’air comprimé.	[]	en_stock	https://pieces-auto.fr/shop/enrouleur-automatique-orientable-de-tuyau-dair-hybride-8-bar-8x12mm-201m-stilker/	2026-07-06 16:41:36.389841+02	2026-07-07 02:26:28.149128+02
38	mallette-136-outils-primetool	Mallette 136 outils – Primetool	\N	\N	19900	EUR	La mallette 136 outils Primetool réunit l'essentiel pour tous vos travaux mécaniques et domestiques. Avec ses outils ergonomiques, son coffret aluminium ultra résistant et son insert en mousse, elle offre une organisation parfaite et une durabilité exceptionnelle. Idéale pour les professionnelles comme les bricoleurs exigeants.	Description\nDécouvrez la mallette 136 outils Primetool, le kit complet pensé pour répondre à tous vos besoins en outillage, que vous soyez professionnel ou passionné de bricolage.\nElle se compose de 4 compartiments parfaitement organisés, regroupant une large sélection d’outils indispensables : pinces, tournevis, douilles, marteau, clés… chaque pièce est conçue avec une ergonomie soignée pour un confort d’utilisation optimal.\nLe coffret est fabriqué en aluminium, garantissant une excellente résistance dans le temps tout en restant léger et facile à transporter. À l’intérieur, un insert en mousse maintient chaque outil en place pour un rangement net, sécurisé et durable.\nLa mallette inclut également un coussin pour s’agenouiller, idéal pour travailler en toute aisance sur des surfaces dures.\nComme tous les produits Primetool, elle bénéficie d’une garantie illimitée, preuve de sa qualité exceptionnelle.\nPoints forts :\n136 outils essentiels et ergonomiques\nCoffret aluminium résistant et élégant\nOrganisation en 4 compartiments + insert mousse\nCoussin d’agenouillement inclus\nGarantie illimitée Primetool\nUne mallette complète, robuste et parfaitement pensée pour vous accompagner dans tous vos travaux.	[]	en_stock	https://pieces-auto.fr/shop/mallette-136-outils-primetool/	2026-07-06 16:41:36.542502+02	2026-07-07 02:27:00.423189+02
46	rampe-de-levage-en-acier-largeur-210mm-1t-par-rampe-lot-de-2-pcs-drakkar	Rampe de levage en acier largeur 210mm 1T par rampe – Lot de 2 pcs – Drakkar	SOD15221	\N	7500	EUR	Idéal pour les garages, ateliers ou particuliers recherchant une solution simple et fiable pour lever un véhicule en toute sécurité.  Caractéristiques du produit :    Capacité 1T par rampe : parfaite pour les véhicules légers et utilitaires légers  Construction acier : grande robustesse et longévité  Largeur 210mm : adaptée à la plupart des largeurs de pneus  Lot de 2 rampes : surélévation rapide et sécurisée de l'essieu avant ou arrière	Description\nGagnez en sécurité et en confort de travail avec ce lot de 2 rampes de levage en acier DRAKKAR. Conçues pour les opérations d’entretien courant (vidange, contrôle visuel, petites réparations…), elles permettent de surélever facilement un véhicule léger tout en garantissant une excellente stabilité.\nFabriquées en acier robuste, ces rampes supportent jusqu’à 1 tonne par rampe et offrent une largeur de 210 mm, idéale pour la plupart des pneumatiques de véhicules de tourisme. Leur structure ajourée facilite l’évacuation des saletés et améliore l’adhérence du pneu.	[]	en_stock	https://pieces-auto.fr/shop/rampe-de-levage-en-acier-largeur-210mm-1t-par-rampe-lot-de-2-pcs-drakkar/	2026-07-06 16:41:36.622972+02	2026-07-07 02:27:33.473596+02
47	rain-x-anti-pluie-200-ml	Traitement Anti-Pluie Pare-Brise 200ml – Rain-X	INTRX26013	\N	1863	EUR	Améliorez instantanément votre visibilité par temps de pluie avec le traitement Rain-X Anti-Pluie. Commandez en ligne et payez en magasin.	Description\nUtilisation :\nNettoyer et sécher les surfaces avant le traitement.\nAppliquer à des températures supérieures à 4°C.\nPulvériser ou verser le produit sur un petit chiffon sec plié.\nAppliquer sur le côté extérieur du pare-brise en faisant des mouvements vigoureux circulaires. Veillez à ce que les surfaces traitées se chevauchent.\nLaisser sécher le produit; il est possible qu’il se forme un voile blanc.\nRenouveler l’application du Rain-X Anti-Pluie pour assurer une couverture complète et uniforme.\nEliminer le dernier voile avec un chiffon sec ou en projetant de l’eau sur la surface et en l’éliminant avec une serviette en papier.\nAutres applications du Rain-X Anti-Pluie :\nEssayer Rain-X Anti-Pluie sur les portes de douche en verre et sur les fenêtres à la maison et observer l’effet perlant sur les gouttes d’eau.\nNe pas utiliser Rain-X Anti-Pluie sur les portes de douche en plastique, les portes de douche avec empreintes ou parties traitées au jet de sable, ou sur les portes de douche en plexiglas et en fibre de verre.\nNe pas utiliser Rain-X Anti-Pluie sur les surfaces plastiques, y compris les visières de moto, les ATV et les panneaux solaires.\nDécouvrez nos produits\nEntretien & Nettoyage	[]	en_stock	https://pieces-auto.fr/shop/rain-x-anti-pluie-200-ml/	2026-07-06 16:41:36.632058+02	2026-07-07 02:27:37.058419+02
51	repulsif-martres-bloc-odorant-concentre-stop-go-difgo	Répulsif martres, bloc odorant concentré STOP&GO – DIF’GO	\N	\N	1820	EUR	Le répulsif STOP & GO offre une protection efficace contre les martres et les fouines. Il agit en diffusant une odeur dissuasive qui éloigne durablement ces animaux et les empêche d’endommager les câbles, durites et matériaux d’insonorisation du compartiment moteur. … En savoir plus	Description\nLe répulsif STOP & GO offre une protection efficace contre les martres et les fouines.\nIl agit en diffusant une odeur dissuasive qui éloigne durablement ces animaux et les empêche d’endommager les câbles, durites et matériaux d’insonorisation du compartiment moteur.\nProtection efficace jusqu’à 6 mois\nLe bloc odorant concentré STOP&GO permet de repousser efficacement les martres, fouines et rongeurs du compartiment moteur des véhicules afin de prévenir les dégâts sur les câbles, durites et isolants.\nGrâce à sa diffusion progressive, il libère une odeur spécifique perçue par la martre comme celle d’un « ennemi dangereux », créant ainsi un environnement dissuasif durable.\nIl peut également être utilisé dans les garages, abris de voiture, greniers ou autres espaces exposés.\nLe bloc se fixe rapidement et agit en continu pour protéger votre véhicule et vos espaces des nuisances et dommages causés par les martres et autres rongeurs.\nCaractéristiques :\nBloc odorant prêt à l’emploi\nDiffusion longue durée (jusqu’à 6 mois)\nSans montage complexe\nS’accroche facilement dans le compartiment moteur, le garage ou l’abri\nSolution simple, pratique et économique\nUtilisation universelle : voiture, maison, jardin, abri de véhicule	[]	en_stock	https://pieces-auto.fr/shop/repulsif-martres-bloc-odorant-concentre-stop-go-difgo/	2026-07-06 16:41:36.660381+02	2026-07-07 02:27:53.727851+02
53	servante-datelier-7-tiroirs-bleu-gris-675x450x900mm-stilker	Servante d’atelier 7 tiroirs bleu/gris 675x450x900mm – Stilker	SOD72517	\N	27900	EUR	Les caractéristiques du produit :   7 tiroirs à roulements à billes : ouverture douce et fiable  Fermeture centralisée : sécurité renforcée (2 clés incluses  Plan de travail avec tapis mousse  Mobilité optimale : 4 roulettes pivotantes, dont 2 freinées	Description\nOrganisez efficacement votre espace de travail avec cette servante d’atelier Stilker, pensée pour offrir robustesse, rangement optimisé et mobilité. Elle dispose de 7 tiroirs montés sur roulements à billes, garantissant une ouverture fluide et durable, même en utilisation intensive.\nSon plan de travail recouvert d’un tapis mousse offre une surface antidérapante, idéale pour poser vos outils ou réaliser de petites interventions en toute sécurité. La fermeture centralisée (2 clés fournies) assure quant à elle une protection complète de votre outillage.\nMontée sur 4 roulettes pivotantes, dont 2 avec freins, cette servante se déplace facilement dans l’atelier tout en restant stable lors de l’utilisation.	[]	en_stock	https://pieces-auto.fr/shop/servante-datelier-7-tiroirs-bleu-gris-675x450x900mm-stilker/	2026-07-06 16:41:36.67969+02	2026-07-07 02:28:01.998094+02
59	anti-humidite	Anti humidité – Bardahl	4452	\N	1270	EUR	L'anti humidité Bardahl, rétablit les contacts grâce à sa formule 2 en 1. Il élimine l'eau de vos contacts et circuits.	Description\nEvite et solutionne les problèmes de démarrage difficile. Elimine l’eau et l’humidité des circuits et contacts électriques. Evite l’oxydation et la corrosion des pièces électriques.	[]	en_stock	https://pieces-auto.fr/shop/anti-humidite/	2026-07-06 16:41:36.74314+02	2026-07-07 02:28:25.893083+02
60	anti-pluie-visiere-bulle	Anti-pluie visière & bulle – GS27	MO110161	\N	1090	EUR	L'Anti Pluie Visière & Bulle GS27® Moto permet d’évacuer rapidement l'eau de pluie et la neige sur les visières et les bulles de carénage. Pour un écoulement rapide, il va transformer l’eau en microbilles. La visibilité sera donc renforcée. Son action à un effet sur la durée. Dangereux – veillez à respecter les précautions d'emploi.	Description\nL’Anti Pluie Visière & Bulle GS27® Moto permet d’évacuer rapidement l’eau de pluie et la neige sur les visières et les bulles de carénage. Pour un écoulement rapide, il va transformer l’eau en microbilles. La visibilité sera donc renforcée. Son action à un effet sur la durée.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/anti-pluie-visiere-bulle/	2026-07-06 16:41:36.749112+02	2026-07-07 02:28:29.938358+02
64	assainissant-casque-bottes-gants	Assainissant casque, bottes & gants – GS27	MO110141	\N	950	EUR	L'Assainissant Casque, Bottes & Gants GS27® Moto permet de désinfecter et nettoyer l'intérieur des casques ainsi que des bottes, des gants, des blousons et des combinaisons. Sa formule contient deux agents actifs qui éliminent les mauvaises odeurs. Un absorbeur d’odeur nouvelle génération pour détruire les odeurs organiques et un agent bactéricide pour éliminer les odeurs d’origine bactérienne. Pour un séchage rapide afin d’utiliser votre casque, vos bottes, vos gants après utilisation du produit, la formule contient de l’alcool. Conseils : utilisez les biocides avec précautions. Avant toute utilisation, lire bien attentivement l'étiquette et les informations concernant le produit. Dangereux – veillez à respecter les précautions d'emploi.	Description\nL’Assainissant Casque, Bottes & Gants GS27® Moto permet de désinfecter et nettoyer l’intérieur des casques ainsi que des bottes, des gants, des blousons et des combinaisons. Sa formule contient deux agents actifs qui éliminent les mauvaises odeurs. Un absorbeur d’odeur nouvelle génération pour détruire les odeurs organiques et un agent bactéricide pour éliminer les odeurs d’origine bactérienne. Pour un séchage rapide afin d’utiliser votre casque, vos bottes, vos gants après utilisation du produit, la formule contient de l’alcool.\nConseils : utilisez les biocides avec précautions. Avant toute utilisation, lire bien attentivement l’étiquette et les informations concernant le produit. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/assainissant-casque-bottes-gants/	2026-07-06 16:41:36.781871+02	2026-07-07 02:28:45.736679+02
73	cire-lustrante-titanium	Cire lustrante titanium + – GS27	CL160291	\N	2490	EUR	La Cire Lustrante Titanium + GS27® permet de protéger votre véhicule et d’obtenir un brillant intense en quelques minutes seulement. Cette cire est pratique et s'applique facilement. Elle ne blanchit pas les plastiques et elle est compatible avec tous les supports : carrosseries mates, plastiques, vitres, métal etc. Son plus ? Elle s’applique avec facilité. Peu importe que la surface soit encore humide ou en plein soleil, La Cire Lustrante Titanium+ redonne brillance et protection. Elle permet aussi de traiter les taches tenaces comme le goudron, la résine etc.	Description\nLa Cire Lustrante Titanium + GS27® permet de protéger votre véhicule et d’obtenir un brillant intense en quelques minutes seulement. Cette cire est pratique et s’applique facilement. Elle ne blanchit pas les plastiques et elle est compatible avec tous les supports : carrosseries mates, plastiques, vitres, métal etc. Son plus ? Elle s’applique avec facilité.\nPeu importe que la surface soit encore humide ou en plein soleil, La Cire Lustrante Titanium+ redonne brillance et protection. Elle permet aussi de traiter les taches tenaces comme le goudron, la résine etc.	[]	en_stock	https://pieces-auto.fr/shop/cire-lustrante-titanium/	2026-07-06 16:41:36.887511+02	2026-07-07 02:29:26.873251+02
77	coffret-desinfectant-ventilation-climatisation-habitacle-new-car	Coffret désinfectant ventilation, climatisation & habitacle new car – GS27	CL160421	\N	1801	EUR	Le Désinfectant Ventilation, Climatisation et habitacle GS27® permet de nettoyer et désinfecter* l’ensemble du circuit d’air. De part son action, il détruit les champignons* et bactéries*, assainit l’habitacle et élimine les mauvaises odeurs. Son application est très simple, il est équipé d’un dispositif de pulvérisation à usage unique. Son plus ? Son parfum voiture neuve.  * Testé selon la norme EN 1276 et EN 1650. Liste des bactéries testées : pseudomonas aeruginosa, escherichia coli, staphylococcus aureus, enterococcus hirae. Dangereux - Respecter les précautions d'emploi. Utilisez les biocides avec précautions. Lisez les étiquettes et les informations concernant ce produit avant toute utilisation.	Description\nLe Désinfectant Ventilation, Climatisation et habitacle GS27® permet de nettoyer et désinfecter* l’ensemble du circuit d’air. De part son action, il détruit les champignons* et bactéries*, assainit l’habitacle et élimine les mauvaises odeurs. Son application est très simple, il est équipé d’un dispositif de pulvérisation à usage unique. Son plus ? Son parfum voiture neuve.\n* Testé selon la norme EN 1276 et EN 1650. Liste des bactéries testées : pseudomonas aeruginosa, escherichia coli, staphylococcus aureus, enterococcus hirae.\nDangereux – Respecter les précautions d’emploi. Utilisez les biocides avec précautions. Lisez les étiquettes et les informations concernant ce produit avant toute utilisation.	[]	en_stock	https://pieces-auto.fr/shop/coffret-desinfectant-ventilation-climatisation-habitacle-new-car/	2026-07-06 16:41:36.935738+02	2026-07-07 02:29:42.744619+02
86	degrippant-lubrifiant	Dégrippant/Lubrifiant – Bardahl	1123	\N	890	EUR	Le dégrippant - lubrifiant Bardahl débloque et a une action anti-corrosion immédiate.	Description\nHaut pouvoir dégrippant. Formule concentrée à haut pouvoir de pénétration. Anti-corrosion. Supprime bruits et grincements. Libère les pièces soudées par la rouille et l’oxydation.	[]	en_stock	https://pieces-auto.fr/shop/degrippant-lubrifiant/	2026-07-06 16:41:37.009806+02	2026-07-07 02:30:17.854036+02
87	demonte-injecteurs	Démonte injecteurs – Bardahl	4319	\N	2605	EUR	Le Démonte injecteurs Bardahl facilite l’extraction et le démontage des injecteurs, bougies d’allumage ou de préchauffage grippés, sans extracteur.	Description\nLe décalaminant curatif Bardahl facilite l’extraction et le démontage des injecteurs, bougies d’allumage ou de préchauffage grippés, sans extracteur.\nSa formule assure une pénétration optimale grâce à ses substances actives très concentrées, permettant de libérer les pièces sans dommage ni risque de casse.\nDécolle les particules de rouille, les résidus de calamine, les dépôts de suies et les restes de joints.	[]	en_stock	https://pieces-auto.fr/shop/demonte-injecteurs/	2026-07-06 16:41:37.016976+02	2026-07-07 02:30:22.098996+02
88	deocar-ball-fleurs-tropicales	Déocar Ball Parfum Fleurs Tropicales – GS27	AC180023	\N	650	EUR	Nouveau concept de parfum d’intérieur automobile : le Deocar® Ball. En s’insérant directement dans les grilles d’aération, il va permettre une diffusion harmonieuse du parfum dans tout l’habitacle. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Le parfum est contenu dans la coque perforée qui le diffuse de manière homogène dans le temps. A vous le nombreux choix de parfums originaux, d’origine française de grande qualité, de très longue durée : jusqu'à 60 jours d'efficacité. Parfum : fleurs tropicales	Description\nNouveau concept de parfum d’intérieur automobile : le Deocar® Ball.\nEn s’insérant directement dans les grilles d’aération, il va permettre une diffusion harmonieuse du parfum dans tout l’habitacle. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Le parfum est contenu dans la coque perforée qui le diffuse de manière homogène dans le temps.\nA vous le nombreux choix de parfums originaux, d’origine française de grande qualité, de très longue durée : jusqu’à 60 jours d’efficacité.\nParfum : fleurs tropicales	[]	en_stock	https://pieces-auto.fr/shop/deocar-ball-fleurs-tropicales/	2026-07-06 16:41:37.033812+02	2026-07-07 02:30:26.270406+02
92	deocar-origin-orange-orientale	Déocar Origin Parfum orange orientale – GS27	AC180019	\N	650	EUR	Déocar® Orign est un nouveau concept de parfum d’intérieur automobile.  En s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours. Parfum : orange orientale.	Description\nDéocar® Orign est un nouveau concept de parfum d’intérieur automobile.\nEn s’insérant directement dans la grille d’aération, le système de ventilation va permette de diffuser harmonieusement son parfum dans tout l’habitacle. Son design est sobre et discret, si bien qu’il se fond dans le tableau de bord. L’insertion de ce désodorisant dans les grilles d’aération est garantie sans risque de rayures. Il est innovant et est composé à 100% de plastique souple. Il ne contient ni gel, ni liquide et ne laissera donc aucune trace de coulure sur le tableau de bord. Son efficacité dure 60 jours.\nParfum : orange orientale.	[]	en_stock	https://pieces-auto.fr/shop/deocar-origin-orange-orientale/	2026-07-06 16:41:37.066058+02	2026-07-07 02:30:42.68814+02
101	detecteur-de-fuites-gaz-air-comprime	Détecteur de fuites gaz & air comprimé – Bardahl	4444	\N	1295	EUR	Le détecteur de fuites gaz & air comprimé Bardahl a une action immédiate et est utilisé pour la haute et basse pression de gaz ou air comprimé	Description\nDétecte sans démontage les fuites et microfuites de gaz ou d’air comprimé. Permet de s’assurer d’une étanchéité parfaite des raccords, soudures, robinets et pneumatiques. Produit actif ininflammable. Action immédiate. Efficace sur tout le système basse et haute pression. Ne provoque pas de réactions dangereuses avec les gaz ou l’air comprimé.	[]	en_stock	https://pieces-auto.fr/shop/detecteur-de-fuites-gaz-air-comprime/	2026-07-06 16:41:37.174357+02	2026-07-07 02:31:18.740495+02
110	eponge-lavage-absolu	Éponge lavage absolu – GS27	OU180150	\N	1450	EUR	L’Eponge de Lavage Absolu GS27® possède 3 surfaces pour 3 actions différentes. Surface 1 – partie chenillée : elle permet d’enlever la saleté sans l’étaler. Surface 2 – partie alvéolée : elle permet de démoustiquer efficacement en évitant les risques de rayures. Surface 3 – partie micro-fibrée : elle permet de venir à bout de toutes les taches tenaces.	Description\nL’Eponge de Lavage Absolu GS27® possède 3 surfaces pour 3 actions différentes.\nSurface 1 – partie chenillée : elle permet d’enlever la saleté sans l’étaler.\nSurface 2 – partie alvéolée : elle permet de démoustiquer efficacement en évitant les risques de rayures.\nSurface 3 – partie micro-fibrée : elle permet de venir à bout de toutes les taches tenaces.	[]	en_stock	https://pieces-auto.fr/shop/eponge-lavage-absolu/	2026-07-06 16:41:37.268755+02	2026-07-07 02:31:55.546933+02
117	fixe-ecrou-moyen-bleu	Fixe écrou moyen – Bardahl	49907	\N	995	EUR	Le Fixe ecrou moyen bleu Bardahl s'applique sur vos filetages afin d'assurer une bonne fixation dans le temps et éviter tout déréglage suite aux vibrations, chaleur, …	Description\nGel bleu anaérobie visqueux, évite le desserrage dû aux chocs et aux vibrations. Protège les pièces de l’oxydation. Tenue en température de -55°C à +180°C.	[]	en_stock	https://pieces-auto.fr/shop/fixe-ecrou-moyen-bleu/	2026-07-06 16:41:37.316246+02	2026-07-07 02:32:23.203896+02
119	gant-de-lavage-triple-action	Gant de lavage triple action – GS27	OU180140	\N	1250	EUR	Le gant de lavage Triple Action GS27® est doté de trois surfaces qui vont vous permettre de nettoyer votre véhicule comme un professionnel. Surface 1 – partie noire : elle permet de retirer toute la saleté sans l’étaler en frottant en douceur. Surface 2 – partie alvéolée : elle permet de démoustiquer de manière efficace en évitant les risques de rayures. Surface 3 – micro-fibrée : elle permet de venir à bout de toutes les taches même les plus tenaces. Son plus ? Il est lavable en machine.	Description\nLe gant de lavage Triple Action GS27® est doté de trois surfaces qui vont vous permettre de nettoyer votre véhicule comme un professionnel.\nSurface 1 – partie noire : elle permet de retirer toute la saleté sans l’étaler en frottant en douceur.\nSurface 2 – partie alvéolée : elle permet de démoustiquer de manière efficace en évitant les risques de rayures.\nSurface 3 – micro-fibrée : elle permet de venir à bout de toutes les taches même les plus tenaces.\nSon plus ? Il est lavable en machine.	[]	en_stock	https://pieces-auto.fr/shop/gant-de-lavage-triple-action/	2026-07-06 16:41:37.359254+02	2026-07-07 02:32:31.257466+02
121	graisse-chaine-tout-terrain-haute-performance	Graisse chaîne tout terrain haute performance – GS27	MO110131	\N	1349	EUR	Spécialement conçu pour les chaines de moto tout terrain et les quads, le Graisse Chaine Tout Terrain GS27® Moto est un lubrifiant pour les conditions extrêmes comme l’eau, le sable, la boue etc. Afin de visualiser les zones déjà lubrifiées et savoir ou réappliquer du produit, il est coloré blanc. Le Graisse Chaine Tout Terrain GS27® empêche l’adhérence du sable. Il est hydrofuge et anticorrosif. Son utilisation permet de protéger et d’augmenter la durée de vie de la chaine. Il a un fort pouvoir pénétrant qui permet de lubrifier les endroits difficiles d’accès. Il diminue les frictions et apporte un gain de puissance. Dangereux – veillez à respecter les précautions d'emploi.	Description\nSpécialement conçu pour les chaines de moto tout terrain et les quads, le Graisse Chaine Tout Terrain GS27® Moto est un lubrifiant pour les conditions extrêmes comme l’eau, le sable, la boue etc.\nAfin de visualiser les zones déjà lubrifiées et savoir ou réappliquer du produit, il est coloré blanc. Le Graisse Chaine Tout Terrain GS27® empêche l’adhérence du sable. Il est hydrofuge et anticorrosif. Son utilisation permet de protéger et d’augmenter la durée de vie de la chaine. Il a un fort pouvoir pénétrant qui permet de lubrifier les endroits difficiles d’accès. Il diminue les frictions et apporte un gain de puissance.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/graisse-chaine-tout-terrain-haute-performance/	2026-07-06 16:41:37.399448+02	2026-07-07 02:32:39.221726+02
126	graisse-tout-usage-en-tube	Graisse tout usage en tube – Bardhal	1529	\N	990	EUR	Graisse tout usage en tube pour une lubrification facile et efficace, idéale pour protéger et entretenir vos pièces mécaniques au quotidien.	Description\nLa graisse tout usage en tube élimine l’eau et l’humidité des circuits et des contacts électriques. Dépose un film protecteur isolant. Evite l’oxydation et la corrosion des pièces électriques. Evite et solutionne les problèmes de démarrage difficile. Excellente adhérence. Résiste à l’eau, à l’oxydation, à la chaleur et au vieillissement prématuré. Anti-usure, extrême pression, anti-corrosion et anti cisaillement. Graisse universelle au lithium. Compatible toute pompe à graisse\nPrincipales caractéristiques :\nGraisse tout usage en tube universelle au lithium, excellente adhérence, anti-usure, extrême pression, anti-corrosion et anti-cisaillement, idéale pour les roulements, articulations, serrures, portes, câbles… Idéale pour tous types de roulements, de moyeux, cardan, palier, chaîne, galet, réducteur ou tout autre engrenage soumis à des conditions difficiles d’utilisation\nExcellente adhérence\nAntiusure, extrême pression, anti-corrosion et anti-cisaillement\nRésiste à l’eau, à l’oxydation, à la chaleur et au vieillissement prématuré\nDécouvrez tous nos produits\nBardhal	[]	en_stock	https://pieces-auto.fr/shop/graisse-tout-usage-en-tube/	2026-07-06 16:41:37.443466+02	2026-07-07 02:32:59.616837+02
135	huile-xtc-5w30-synthese-c3	Huile XTC 5w30 synthèse c3 – Bardahl	36313	\N	3790	EUR	L'huile XTC 5w30 synthèse c3 Bardahl, Synthétique- Essence & Diesel,est une huile à haut pouvoir lubrifiant	Description\nHuile semi-synthétique, haute performance, pour moteurs essence et diesel . Convient à tous types de moteurs turbo-compressés ou non, équipés ou non d’un FAP. Pour des intervalles de vidange prolongés. Excellente protection lors de la mise en température et aux différents régimes du moteur. La XTC 5W30 BARDAHL est une huile mid SAPS (teneur en cendres réduite). Niveau de propreté optimal.	[]	en_stock	https://pieces-auto.fr/shop/huile-xtc-5w30-synthese-c3/	2026-07-06 16:41:37.558514+02	2026-07-07 02:33:36.326491+02
145	huile-xts-0w30-100-synthese-a1-b1-a5-b5-vw-503-00-506-00-506-01	Huile XTS 0w30 100 % synthèse a1/b1 a5/b5 vw 503.00, 506.00, 506.01 – Bardahl	36133	\N	7490	EUR	L'huile XTS 0w30 100 % synthèse a1/b1 a5/b5 vw 503.00, 506.00, 506.01 Bardahl, 100% Synthétique - Essence & Diesel est une huile à haut pouvoir lubrifiant	Description\nHuile 100% synthèse, à base d’additifs de performance de dernière génération, pour véhicules essence et diesel. Réduit la friction, élimine les boues, et optimise la consommation de carburant. Protection générale assurée. La XTS 0W30 BARDAHL offre d’excellentes performances à basse température. Formulée pour satisfaire au programme « Longlife 2 » (VW). Réduit la consommation de carburant.	[]	en_stock	https://pieces-auto.fr/shop/huile-xts-0w30-100-synthese-a1-b1-a5-b5-vw-503-00-506-00-506-01/	2026-07-06 16:41:37.622233+02	2026-07-07 02:34:16.409347+02
155	joint-silicone-or-special-diesel	Joint silicone or spécial Diesel – Bardahl	5003	\N	1495	EUR	Le joint silicone or Spécial Diesel Bardahl est compatible tous type de carter et joints. Il sèche rapidement et est utilisable de -60 °c à +250 °c	Description\nPâte d’étanchéité spécialediesel conçue pourremplacer les joints desmoteurs diesel (carterd’huile, distribution,culbuteur, pompe injection,boîte, turbo etcâ€¦).Grande résistance auxfortes pressions ET auxvibrations.Résiste aux huilessynthétiques et auxtempératures élevées.Egalise les surfaces.Souple et élastique.S’utilise sur pièces métal,plastique et peintes.	[]	en_stock	https://pieces-auto.fr/shop/joint-silicone-or-special-diesel/	2026-07-06 16:41:37.739935+02	2026-07-07 02:34:56.205744+02
157	kit-de-renovation-optiques-de-phares	Kit de Rénovation Optiques de Phares – Holts	HREP0031A	\N	2990	EUR	Vos optiques de phares sont ternis, jaunis ternes ou rayés ?  Problème résolu avec Holts et son kit de Rénovation Optiques de Phares.   Redonne clarté et propreté à vos feux  Elimine les rayures profondes et l’oxydation  Augmente la visibilité en voiture  Vous aide à passer le contrôle technique  Rapide et facile à utiliser	Description\nUtiliser la tête de polissage en mousse et le Rénovateur Optique de Phares et s’assurer qu’il ne reste pas de résidu pour une meilleure finition. Pulvériser une légère couche de Protecteur Optique de phares Holts pour protéger l’optique à long terme.	[]	en_stock	https://pieces-auto.fr/shop/kit-de-renovation-optiques-de-phares/	2026-07-06 16:41:37.758756+02	2026-07-07 02:35:04.488001+02
159	kit-entretien-habitacle-animaux-de-compagnie	Kit entretien habitacle animaux de compagnie – GS27	CL172015	\N	3340	EUR	Le Kit Entretien Habitacle spécial animal de compagnie GS27® permet un nettoyage complet de l’intérieur de l’habitacle mais aussi de l’intérieur de vos habitations. Ce kit est composé de trois produits : Nettoyant Désinfectant Toutes Surfaces, Brosse Capture-Poils, Déocar Spray. Ce kit garantit : -Capturer les poils, nettoyer et désinfecter. -Eradiquer les mauvaises odeurs. Il est sans risque pour vos animaux	Description\nLe Kit Entretien Habitacle spécial animal de compagnie GS27® permet un nettoyage complet de l’intérieur de l’habitacle mais aussi de l’intérieur de vos habitations. Ce kit est composé de trois produits : Nettoyant Désinfectant Toutes Surfaces, Brosse Capture-Poils, Déocar Spray. Ce kit garantit :\n-Capturer les poils, nettoyer et désinfecter.\n-Eradiquer les mauvaises odeurs.\nIl est sans risque pour vos animaux	[]	en_stock	https://pieces-auto.fr/shop/kit-entretien-habitacle-animaux-de-compagnie/	2026-07-06 16:41:37.786417+02	2026-07-07 02:35:12.655061+02
163	kit-vidange	Kit de vidange 4 pcs – Stilker	SOD28545	\N	2500	EUR	Effectuez vos vidanges simplement et proprement avec ce kit complet de vidange Stilker, conçu pour faciliter l'entretien de votre véhicule.	Description\nEffectuez vos vidanges simplement et proprement avec ce kit complet de vidange Stilker, conçu pour faciliter l’entretien de votre véhicule. Que vous soyez un particulier ou un professionnel, cet ensemble pratique regroupe tous les accessoires indispensables pour un changement d’huile efficace et salissures.\nCaractéristiques :\n– Tout-en-un : contient tous les outils nécessaires pour réaliser la vidange sans matériel supplémentaire\n– Solide et durable : matériaux résistants aux huiles et solvants\n– Facile à utiliser : convient à tous les niveaux, du bricoleur débutant au mécanicien confirmé	[]	en_stock	https://pieces-auto.fr/shop/kit-vidange/	2026-07-06 16:41:37.848291+02	2026-07-07 02:35:28.307476+02
174	lustreur-express-titanium	Lustreur express titanium – GS27	CL120221	\N	1650	EUR	Le Lustreur Express Titanium® GS27 Classics® permet de nettoyer et faire briller votre véhicule de manière instantanée, sans rinçage et uniquement à l’aide d’une microfibre. La solution la plus rapide et la plus efficace pour une voiture propre et brillante. Brillance et protection longue durée garantie grâce à sa formule enrichie en Titanium® qui va déposer un film très résistant. Aussi optimal pour une utilisation sur peinture mate	Description\nLe Lustreur Express Titanium® GS27 Classics® permet de nettoyer et faire briller votre véhicule de manière instantanée, sans rinçage et uniquement à l’aide d’une microfibre. La solution la plus rapide et la plus efficace pour une voiture propre et brillante. Brillance et protection longue durée garantie grâce à sa formule enrichie en Titanium® qui va déposer un film très résistant.\nAussi optimal pour une utilisation sur peinture mate	[]	en_stock	https://pieces-auto.fr/shop/lustreur-express-titanium/	2026-07-06 16:41:37.937164+02	2026-07-07 02:36:12.148036+02
182	microfibre-sechage-extreme	Microfibre séchage extrême – GS27	OU180170	\N	1690	EUR	La microfibre Séchage Extrême GS27® permet d’enlever aisément l’eau, et donc les traces au séchage, après un rinçage sur votre carrosserie. Elle absorbe trois fois plus d’eau qu’une peau de chamois traditionnelle. Elle a un fort pouvoir absorbant grâce à sa texture nid d’abeille. Son plus ? Son format XXL (600 x 800mm).  La microfibre Séchage Extrême GS27® permet d’enlever aisément l’eau, et donc les traces au séchage, après un rinçage sur votre carrosserie. Elle absorbe trois fois plus d’eau qu’une peau de chamois traditionnelle. Elle a un fort pouvoir absorbant grâce à sa texture nid d’abeille. Son plus ? Son format XXL (600 x 800mm).	Description\nLa microfibre Séchage Extrême GS27® permet d’enlever aisément l’eau, et donc les traces au séchage, après un rinçage sur votre carrosserie. Elle absorbe trois fois plus d’eau qu’une peau de chamois traditionnelle. Elle a un fort pouvoir absorbant grâce à sa texture nid d’abeille. Son plus ? Son format XXL (600 x 800mm).\nLa microfibre Séchage Extrême GS27® permet d’enlever aisément l’eau, et donc les traces au séchage, après un rinçage sur votre carrosserie. Elle absorbe trois fois plus d’eau qu’une peau de chamois traditionnelle. Elle a un fort pouvoir absorbant grâce à sa texture nid d’abeille. Son plus ? Son format XXL (600 x 800mm).	[]	en_stock	https://pieces-auto.fr/shop/microfibre-sechage-extreme/	2026-07-06 16:41:37.990548+02	2026-07-07 02:36:43.433566+02
184	nettoyant-filtre-a-particules	Nettoyant pour filtre à particules – Bardahl	1042	\N	8272	EUR	Le nettoyant filtre a particules Bardahl, evite l'encrassement baisse la consommation se verse dans le carburant.	Description\nAbaisse la température de combustion des particules de suie.\nEvite l’encrassement des filtres à particules dû à l’accumulation des suies (particules non brûlées).\nN’altère pas les composants (métaux précieux) permettant de pièger et brûler les particules nocives.\nEvite les surconsommations, la perte de puissance et le remplacement du filtre à particules. Dans le cas d’une obstruction du filtre, les gaz d’échappement ne peuvent plus sortir et le moteur cale par étouffement.\nPermet de brûler et de détruire plus facilement les suies retenues à l’interieur du filtre.\nProlonge la durée de vie et le bon fonctionnement des filtres à particules.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-filtre-a-particules/	2026-07-06 16:41:38.005517+02	2026-07-07 02:36:51.637669+02
190	nettoyant-insectes-fientes	Nettoyant insectes & fientes – GS27	CL120181	\N	1150	EUR	Le Nettoyant Insectes & Fientes GS27 Classics® permet d’enlever en un seul geste toutes les traces d'insectes & de fientes d'oiseaux sur les différentes parties de votre véhicule. Les insectes vont se décoller facilement grâce à sa formule concentrée au fort pouvoir mouillant. Il peut s'appliquer sur toutes les surfaces extérieures de la voiture (carrosserie, vitres, plastiques, etc.). Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Nettoyant Insectes & Fientes GS27 Classics® permet d’enlever en un seul geste toutes les traces d’insectes & de fientes d’oiseaux sur les différentes parties de votre véhicule. Les insectes vont se décoller facilement grâce à sa formule concentrée au fort pouvoir mouillant. Il peut s’appliquer sur toutes les surfaces extérieures de la voiture (carrosserie, vitres, plastiques, etc.). Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-insectes-fientes/	2026-07-06 16:41:38.047017+02	2026-07-07 02:37:15.7389+02
192	nettoyant-jantes-gel	Nettoyant jantes gel – GS27	CL120122	\N	1390	EUR	Grâce à sa formulation en gel, Le Nettoyant Jantes Gel GS27 Classics® adhère totalement à la jante et permet un nettoyage plus précis et plus en profondeur. Il enlève absolument tous les résidus de plaquettes de frein et les graisses incrustées sur les jantes et les enjoliveurs pour un résultat brillant. Dangereux – veillez à respecter les précautions d'emploi.	Description\nGrâce à sa formulation en gel, Le Nettoyant Jantes Gel GS27 Classics® adhère totalement à la jante et permet un nettoyage plus précis et plus en profondeur. Il enlève absolument tous les résidus de plaquettes de frein et les graisses incrustées sur les jantes et les enjoliveurs pour un résultat brillant.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-jantes-gel/	2026-07-06 16:41:38.071304+02	2026-07-07 02:37:23.627332+02
196	nettoyant-protecteur-toutes-surfaces	Nettoyant protecteur toutes surfaces – GS27	MO110162	\N	1050	EUR	Le Nettoyant Protecteur Toutes Surfaces GS27® Moto est un produit complet tout en un. Il élimine les taches tenaces, il protège les surfaces de la moto et il redonne une brillance profonde. En se pulvérisant directement sur toutes les surfaces (carénage, jantes, chromes, cuirs) il est pratique à utiliser. Il élimine de manière efficace toutes les taches incrustées de type goudron, résine, graisse, huile, insectes et colle. En protégeant toutes les surfaces, il limite l’encrassement, protège de la corrosion et contre toutes les agressions extérieures (UV, pluie, neige, sel). Son plus ? Il peut s’utiliser sur les peintures mates.	Description\nLe Nettoyant Protecteur Toutes Surfaces GS27® Moto est un produit complet tout en un. Il élimine les taches tenaces, il protège les surfaces de la moto et il redonne une brillance profonde. En se pulvérisant directement sur toutes les surfaces (carénage, jantes, chromes, cuirs) il est pratique à utiliser. Il élimine de manière efficace toutes les taches incrustées de type goudron, résine, graisse, huile, insectes et colle. En protégeant toutes les surfaces, il limite l’encrassement, protège de la corrosion et contre toutes les agressions extérieures (UV, pluie, neige, sel). Son plus ? Il peut s’utiliser sur les peintures mates.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-protecteur-toutes-surfaces/	2026-07-06 16:41:38.097084+02	2026-07-07 02:37:39.765439+02
200	nettoyant-tous-textiles-avec-brosse	Nettoyant tous textiles avec brosse – GS27	CL110261	\N	1490	EUR	Le Nettoyant Tous Textiles Triple Action GS27® Classics va permettre d’éradiquer instantanément toutes les taches sur les tissus de votre véhicule. Sa mousse active va nettoyer en profondeur et redonner la couleur d’origine des tissus. Désincruster les salissures les plus tenaces n’aura jamais été aussi facile grâce à sa brosse spécifique. Avec sa forme allongée, vous pourrez nettoyer aisément les coins des sièges et banquettes. Doté d’un neutralisateur d'odeurs, il éliminera les mauvaises odeurs tout en apportant une note de fraicheur à vos textiles. Dangereux – veillez à respecter les précautions d'emploi.	Description\nLe Nettoyant Tous Textiles Triple Action GS27® Classics va permettre d’éradiquer instantanément toutes les taches sur les tissus de votre véhicule.  Sa mousse active va nettoyer en profondeur et redonner la couleur d’origine des tissus. Désincruster les salissures les plus tenaces n’aura jamais été aussi facile grâce à sa brosse spécifique. Avec sa forme allongée, vous pourrez nettoyer aisément les coins des sièges et banquettes. Doté d’un neutralisateur d’odeurs, il éliminera les mauvaises odeurs tout en apportant une note de fraicheur à vos textiles. Dangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-tous-textiles-avec-brosse/	2026-07-06 16:41:38.132095+02	2026-07-07 02:37:56.188353+02
207	nettoyant-vitres-anti-buee	Nettoyant vitres anti buée – GS27	CL120211	\N	1190	EUR	Avec sa formule spécifique qui évite la formation de buée due au froid, l’humidité, la fumée de tabac, le Nettoyant Vitres – formule antibuée – GS27 Classics® nettoie les vitres sans laisser de traces. Il est à la fois efficace et très agréable à utiliser grâce à son parfum pomme. Dangereux – veillez à respecter les précautions d'emploi.	Description\nAvec sa formule spécifique qui évite la formation de buée due au froid, l’humidité, la fumée de tabac, le Nettoyant Vitres – formule antibuée – GS27 Classics® nettoie les vitres sans laisser de traces.\nIl est à la fois efficace et très agréable à utiliser grâce à son parfum pomme.\nDangereux – veillez à respecter les précautions d’emploi.	[]	en_stock	https://pieces-auto.fr/shop/nettoyant-vitres-anti-buee/	2026-07-06 16:41:38.197073+02	2026-07-07 02:38:24.686177+02
211	pad-applicateur-ultra-doux	Pad applicateur ultra doux – GS27	OU180010	\N	1299	EUR	Les Pads Applicateurs MicroFibre GS27® s’utilisent avec un efface rayures, un polish et un lustreur GS27®. Il y a également possibilité de l’utiliser pour l’intérieur de l’habitacle sur des surfaces plastiques ou sur du cuir. Le pad a une forme ronde et est muni d’un élastique pour une prise en main facilitée. Côté texture, il est doux, ce qui permet d’éviter tout accroc possible. Lot de 2 pads.	Description\nLes Pads Applicateurs MicroFibre GS27® s’utilisent avec un efface rayures, un polish et un lustreur GS27®. Il y a également possibilité de l’utiliser pour l’intérieur de l’habitacle sur des surfaces plastiques ou sur du cuir. Le pad a une forme ronde et est muni d’un élastique pour une prise en main facilitée. Côté texture, il est doux, ce qui permet d’éviter tout accroc possible. Lot de 2 pads.	[]	en_stock	https://pieces-auto.fr/shop/pad-applicateur-ultra-doux/	2026-07-06 16:41:38.222015+02	2026-07-07 02:38:40.529888+02
229	renovateur-alu-chrome	Rénovateur alu & chrome – GS27	MO150101	\N	1190	EUR	Le Rénovateur Alu & Chromes GS27® Moto permet de désoxyder, rénover et faire briller tous les métaux. Il a une action abrasive qui supprime la rouille et désoxyde en profondeur. Il polit et redonne la brillance du neuf tout en déposant un film protecteur anticorrosion et anti-oxydation.	Description\nLe Rénovateur Alu & Chromes GS27® Moto permet de désoxyder, rénover et faire briller tous les métaux. Il a une action abrasive qui supprime la rouille et désoxyde en profondeur. Il polit et redonne la brillance du neuf tout en déposant un film protecteur anticorrosion et anti-oxydation.	[]	en_stock	https://pieces-auto.fr/shop/renovateur-alu-chrome/	2026-07-06 16:41:38.451574+02	2026-07-07 02:39:52.359739+02
236	renovateur-pneus	Rénovateur pneus – GS27	CL110101	\N	1390	EUR	Rénovez sans effort les pneumatiques de votre véhicule avec Le Rénovateur Pneus GS27 Classics®. Le caoutchouc va retrouver sa couleur naturelle et vos pneumatiques seront comme neufs ! Il peut s’appliquer sur tous les types de pneumatiques. Dangereux – veillez à respecter les précautions d'emploi	Description\nRénovez sans effort les pneumatiques de votre véhicule avec Le Rénovateur Pneus GS27 Classics®. Le caoutchouc va retrouver sa couleur naturelle et vos pneumatiques seront comme neufs ! Il peut s’appliquer sur tous les types de pneumatiques. Dangereux – veillez à respecter les précautions d’emploi	[]	en_stock	https://pieces-auto.fr/shop/renovateur-pneus/	2026-07-06 16:41:38.524833+02	2026-07-07 02:40:20.684437+02
239	repare-crevaison-express-500-ml-gs27	Répare crevaison express 500 ml – GS27	MO110221-1	\N	850	EUR	Le répare crevaison offre une solution rapide et efficace en cas de pneu crevé.  Il colmate la fuite et regonfle le pneu en quelques minutes, sans outil ni démontage, pour vous permettre de reprendre la route rapidement.	Description\nRépare et regonfle votre pneu en 2 minutes !\nLe répare crevaison permet de colmater rapidement une fuite et de regonfler votre pneu sans avoir à le démonter. Idéal en cas d’urgence, il vous permet de reprendre la route rapidement et en toute simplicité.\nCaractéristiques :\n– Intervention rapide en seulement 2 minutes\n– Sans outil et sans démontage\n– Compatible avec tous types de pneus (avec ou sans chambre à air)\n– Utilisation polyvalente : voiture, moto, scooter, vélo, 4×4, remorque, etc.\n– Solution pratique à conserver dans votre véhicule pour faire face aux imprévus et éviter l’immobilisation en cas de crevaison.	[]	en_stock	https://pieces-auto.fr/shop/repare-crevaison-express-500-ml-gs27/	2026-07-06 16:41:38.550284+02	2026-07-07 02:40:32.515391+02
243	shampooing-evolution-avec-diffuseur	Shampooing évolution + avec diffuseur – GS27	CL130141	\N	1790	EUR	Doté d’un diffuseur spécifique qui se connecte directement sur votre arrivée d’eau, le Shampooing Evolution + GS27® Classics ne nécessite aucun seau. La dissolution se fait directement grâce au diffuseur, à vous de pulvériser sur votre voiture. Ce shampoing dégraissant apporte une finition brillante grâce à sa formule ultra moussante. Son plus ? Son parfum pamplemousse. Vous pouvez réaliser jusqu’à 15 lavages.	Description\nDoté d’un diffuseur spécifique qui se connecte directement sur votre arrivée d’eau, le Shampooing Evolution + GS27® Classics ne nécessite aucun seau. La dissolution se fait directement grâce au diffuseur, à vous de pulvériser sur votre voiture. Ce shampoing dégraissant apporte une finition brillante grâce à sa formule ultra moussante. Son plus ? Son parfum pamplemousse. Vous pouvez réaliser jusqu’à 15 lavages.	[]	en_stock	https://pieces-auto.fr/shop/shampooing-evolution-avec-diffuseur/	2026-07-06 16:41:38.59517+02	2026-07-07 02:40:49.157092+02
246	soin-des-plastiques-triple-action	Soin des plastiques triple action – GS27	CL110231	\N	1550	EUR	Le Soin des Plastiques GS27® – Triple Action entretient les plastiques intérieurs de votre véhicule. Il permet de dépoussiérer, rénover et protéger les tableaux de bord exposés aux UVs. Sa mousse intégrée permet d’appliquer et d’essuyer facilement le produit. Son plus ? Son parfum « Fruits de la Passion ». Il peut s’appliquer sur tous les plastiques, vinyle, skaï, bois vernis, caoutchouc.	Description\nLe Soin des Plastiques GS27® – Triple Action  entretient les plastiques intérieurs de votre véhicule. Il permet de dépoussiérer, rénover et protéger les tableaux de bord exposés aux UVs. Sa mousse intégrée permet d’appliquer et d’essuyer facilement le produit. Son plus ? Son parfum « Fruits de la Passion ». Il peut s’appliquer sur tous les plastiques, vinyle, skaï, bois vernis, caoutchouc.	[]	en_stock	https://pieces-auto.fr/shop/soin-des-plastiques-triple-action/	2026-07-06 16:41:38.631377+02	2026-07-07 02:41:01.348759+02
257	teinteur-pare-chocs-noir	Teinteur spécial pare-chocs noir – GS27	CL150122	\N	1690	EUR	Le Teinteur Pare-Chocs Noir GS27 Classics® permet de raviver et re-teinter facilement toutes les parties plastiques du véhicule. Les parties traitées vont garder plus longtemps leur couleur et auront une meilleure résistance face aux différentes intempéries. Ce produit est à base de résine de synthèse. Et il est sans solvant et sans silicone. L’application de ce produit est possible sur tous les plastiques noirs du véhicule tels que : pare-chocs PVC ou ABS, spoilers, rétroviseurs, tableaux de bord etc.	Description\nLe Teinteur Pare-Chocs Noir GS27 Classics® permet de raviver et re-teinter facilement toutes les parties plastiques du véhicule. Les parties traitées vont garder plus longtemps leur couleur et auront une meilleure résistance face aux différentes intempéries. Ce produit est à base de résine de synthèse. Et il est sans solvant et sans silicone. L’application de ce produit est possible sur tous les plastiques noirs du véhicule tels que : pare-chocs PVC ou ABS, spoilers, rétroviseurs, tableaux de bord etc.	[]	en_stock	https://pieces-auto.fr/shop/teinteur-pare-chocs-noir/	2026-07-06 16:41:38.747807+02	2026-07-07 02:41:45.160452+02
\.


--
-- Name: admin_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_users_id_seq', 1, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 1554, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, true);


--
-- Name: order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_number_seq', 1, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_id_seq', 796, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 259, true);


--
-- Name: admin_users admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_email_key UNIQUE (email);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (product_id, category_id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_slug_key UNIQUE (slug);


--
-- Name: idx_products_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_reference ON public.products USING btree (reference);


--
-- Name: idx_products_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_title ON public.products USING btree (lower(title));


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: product_categories product_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_images product_images_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict UnSH1XGXPeOrBBlrtuA1BrksWQVc98mczbEefDormzsuYBrWiE0nEYagEIuZbUG

