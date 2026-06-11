// Node Key constraints
CREATE CONSTRAINT person_nk IF NOT EXISTS FOR (n:Person) REQUIRE n.id IS NODE KEY;
CREATE CONSTRAINT movie_nk IF NOT EXISTS FOR (n:Movie) REQUIRE n.id IS NODE KEY;
CREATE CONSTRAINT genre_nk IF NOT EXISTS FOR (n:Genre) REQUIRE n.name IS NODE KEY;

// Relationship Key constraints

CREATE CONSTRAINT acted_in_rk IF NOT EXISTS FOR ()-[r:ACTED_IN]-() REQUIRE r.id IS RELATIONSHIP KEY;
CREATE CONSTRAINT directed_rk IF NOT EXISTS FOR ()-[r:DIRECTED]-() REQUIRE r.id IS RELATIONSHIP KEY;
CREATE CONSTRAINT produced_rk IF NOT EXISTS FOR ()-[r:PRODUCED]-() REQUIRE r.id IS RELATIONSHIP KEY;
CREATE CONSTRAINT wrote_rk IF NOT EXISTS FOR ()-[r:WROTE]-() REQUIRE r.id IS RELATIONSHIP KEY;
CREATE CONSTRAINT follows_rk IF NOT EXISTS FOR ()-[r:FOLLOWS]-() REQUIRE r.id IS RELATIONSHIP KEY;
CREATE CONSTRAINT reviewed_rk IF NOT EXISTS FOR ()-[r:REVIEWED]-() REQUIRE r.id IS RELATIONSHIP KEY;

// Existence constraints

CREATE CONSTRAINT exist_person_name IF NOT EXISTS FOR (n:Person) REQUIRE n.name IS NOT NULL;
CREATE CONSTRAINT exist_movie_title IF NOT EXISTS FOR (n:Movie) REQUIRE n.title IS NOT NULL;

// Property Type constraints

CREATE CONSTRAINT type_person_id IF NOT EXISTS FOR (n:Person) REQUIRE n.id IS TYPED STRING;
CREATE CONSTRAINT type_person_name IF NOT EXISTS FOR (n:Person) REQUIRE n.name IS TYPED STRING;
CREATE CONSTRAINT type_person_born IF NOT EXISTS FOR (n:Person) REQUIRE n.born IS TYPED DATE;
CREATE CONSTRAINT type_person_born_in IF NOT EXISTS FOR (n:Person) REQUIRE n.bornIn IS TYPED STRING;
CREATE CONSTRAINT type_person_born_position IF NOT EXISTS FOR (n:Person) REQUIRE n.bornPosition IS TYPED POINT;

CREATE CONSTRAINT type_movie_id IF NOT EXISTS FOR (n:Movie) REQUIRE n.id IS TYPED STRING;
CREATE CONSTRAINT type_movie_title IF NOT EXISTS FOR (n:Movie) REQUIRE n.title IS TYPED STRING;
CREATE CONSTRAINT type_movie_released IF NOT EXISTS FOR (n:Movie) REQUIRE n.released IS TYPED DATE;
CREATE CONSTRAINT type_movie_tagline IF NOT EXISTS FOR (n:Movie) REQUIRE n.tagline IS TYPED STRING;

CREATE CONSTRAINT type_genre_name IF NOT EXISTS FOR (n:Genre) REQUIRE n.genre IS TYPED STRING;

CREATE CONSTRAINT type_acted_in_roles IF NOT EXISTS FOR ()-[r:ACTED_IN]-() REQUIRE r.roles IS TYPED LIST<STRING NOT NULL>;

// Generate graph

CREATE (thriller:Genre {name: "Triller"})
CREATE (scifi:Genre {name: "Sci-Fi"})
CREATE (action:Genre {name: "Action"})
CREATE (imax:Genre {name: "IMAX"})
CREATE (adventure:Genre {name: "Adventure"})

CREATE (TheMatrix:Movie {id: "the matrix", title:"The Matrix", released: date({year: 1999}), tagline:'Welcome to the Real World'})
CREATE (Keanu:Person {id: "keanu reeves", name: "Keanu Reeves", born: date({year: 1964, month: 9, day: 2})})
SET Keanu.bornIn = 'Beirut, Lebanon'
SET Keanu.bornPosition = point({latitude: 33.8938, longitude: 35.5018})
CREATE (Carrie:Person {id: "carrie-anne moss", name: "Carrie-Anne Moss", born: date({year: 1967, month: 8, day: 21})})
SET Carrie.bornIn = 'Burnaby, British Columbia, Canada'
SET Carrie.bornPosition = point({latitude: 49.2488, longitude: -122.9805})
CREATE (Laurence:Person {id: "laurence fishburne", name: "Laurence Fishburne", born: date({year: 1961, month: 7, day: 30})})
SET Laurence.bornIn = 'Augusta, Georgia, USA'
SET Laurence.bornPosition = point({latitude: 33.4735, longitude: -82.0105})
CREATE (Hugo:Person {id: "hugo weaving", name: "Hugo Weaving", born: date({year: 1960, month: 4, day: 4})})
SET Hugo.bornIn = 'Ibadan, Nigeria'
SET Hugo.bornPosition = point({latitude: 7.3775, longitude: 3.9470})
CREATE (LillyW:Person {id: "lilly wachowski", name: "Lilly Wachowski", born: date({year: 1967, month: 12, day: 29})})
SET LillyW.bornIn = 'Chicago, Illinois, USA'
SET LillyW.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE (LanaW:Person {id: "lana wachowski", name: "Lana Wachowski", born: date({year: 1965, month: 6, day: 21})})
SET LanaW.bornIn = 'Chicago, Illinois, USA'
SET LanaW.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE (JoelS:Person {id: "joel silver", name: "Joel Silver", born: date({year: 1952, month: 7, day: 14})})
SET JoelS.bornIn = 'South Orange, New Jersey, USA'
SET JoelS.bornPosition = point({latitude: 40.7479, longitude: -74.2601})

CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__the matrix', roles:['Neo']}]->(TheMatrix),
(Carrie)-[:ACTED_IN {id:'carrie-anne moss__ACTED_IN__the matrix', roles:['Trinity']}]->(TheMatrix),
(Laurence)-[:ACTED_IN {id:'laurence fishburne__ACTED_IN__the matrix', roles:['Morpheus']}]->(TheMatrix),
(Hugo)-[:ACTED_IN {id:'hugo weaving__ACTED_IN__the matrix', roles:['Agent Smith']}]->(TheMatrix),
(LillyW)-[:DIRECTED {id: 'lilly wachowski__DIRECTED__the matrix'}]->(TheMatrix),
(LanaW)-[:DIRECTED {id: 'lana wachowski__DIRECTED__the matrix'}]->(TheMatrix),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__the matrix'}]->(TheMatrix)
CREATE (TheMatrix)-[:IN_GENRE]->(thriller),
(TheMatrix)-[:IN_GENRE]->(scifi),
(TheMatrix)-[:IN_GENRE]->(action)

CREATE (Emil:Person {id: "emil eifrem", name: "Emil Eifrem", born: date({year: 1978})})
CREATE (Emil)-[:ACTED_IN {id:'emil eifrem__ACTED_IN__the matrix', roles:["Emil"]}]->(TheMatrix)

CREATE (TheMatrixReloaded:Movie {id: "the matrix reloaded", title:"The Matrix Reloaded", released: date({year: 2003}), tagline:'Free your mind'})
CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__the matrix reloaded', roles:['Neo']}]->(TheMatrixReloaded),
(Carrie)-[:ACTED_IN {id:'carrie-anne moss__ACTED_IN__the matrix reloaded', roles:['Trinity']}]->(TheMatrixReloaded),
(Laurence)-[:ACTED_IN {id:'laurence fishburne__ACTED_IN__the matrix reloaded', roles:['Morpheus']}]->(TheMatrixReloaded),
(Hugo)-[:ACTED_IN {id:'hugo weaving__ACTED_IN__the matrix reloaded', roles:['Agent Smith']}]->(TheMatrixReloaded),
(LillyW)-[:DIRECTED {id: 'lilly wachowski__DIRECTED__the matrix reloaded'}]->(TheMatrixReloaded),
(LanaW)-[:DIRECTED {id: 'lana wachowski__DIRECTED__the matrix reloaded'}]->(TheMatrixReloaded),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__the matrix reloaded'}]->(TheMatrixReloaded)

CREATE (TheMatrixReloaded)-[:IN_GENRE]->(thriller),
(TheMatrixReloaded)-[:IN_GENRE]->(scifi),
(TheMatrixReloaded)-[:IN_GENRE]->(action),
(TheMatrixReloaded)-[:IN_GENRE]->(adventure),
(TheMatrixReloaded)-[:IN_GENRE]->(imax)

CREATE (TheMatrixRevolutions:Movie {id: "the matrix revolutions", title:"The Matrix Revolutions", released: date({year: 2003}), tagline:'Everything that has a beginning has an end'})
CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__the matrix revolutions', roles:['Neo']}]->(TheMatrixRevolutions),
(Carrie)-[:ACTED_IN {id:'carrie-anne moss__ACTED_IN__the matrix revolutions', roles:['Trinity']}]->(TheMatrixRevolutions),
(Laurence)-[:ACTED_IN {id:'laurence fishburne__ACTED_IN__the matrix revolutions', roles:['Morpheus']}]->(TheMatrixRevolutions),
(Hugo)-[:ACTED_IN {id:'hugo weaving__ACTED_IN__the matrix revolutions', roles:['Agent Smith']}]->(TheMatrixRevolutions),
(LillyW)-[:DIRECTED {id: 'lilly wachowski__DIRECTED__the matrix revolutions'}]->(TheMatrixRevolutions),
(LanaW)-[:DIRECTED {id: 'lana wachowski__DIRECTED__the matrix revolutions'}]->(TheMatrixRevolutions),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__the matrix revolutions'}]->(TheMatrixRevolutions)

CREATE (TheDevilsAdvocate:Movie {id: "the devil's advocate", title:"The Devil's Advocate", released: date({year: 1997}), tagline:'Evil has its winning ways'})
CREATE (Charlize:Person {id: "charlize theron", name: "Charlize Theron", born: date({year: 1975, month: 8, day: 7})})
SET Charlize.bornIn = 'Benoni, South Africa'
SET Charlize.bornPosition = point({latitude: -26.1564, longitude: 28.3694})
CREATE (Al:Person {id: "al pacino", name: "Al Pacino", born: date({year: 1940, month: 4, day: 25})})
SET Al.bornIn = 'New York City, New York, USA'
SET Al.bornPosition = point({latitude: 40.7128, longitude: -74.0060})
CREATE (Taylor:Person {id: "taylor hackford", name: "Taylor Hackford", born: date({year: 1944, month: 12, day: 31})})
SET Taylor.bornIn = 'Santa Barbara, California, USA'
SET Taylor.bornPosition = point({latitude: 34.4208, longitude: -119.6982})

CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__the devil\'s advocate', roles:['Kevin Lomax']}]->(TheDevilsAdvocate),
(Charlize)-[:ACTED_IN {id:'charlize theron__ACTED_IN__the devil\'s advocate', roles:['Mary Ann Lomax']}]->(TheDevilsAdvocate),
(Al)-[:ACTED_IN {id:'al pacino__ACTED_IN__the devil\'s advocate', roles:['John Milton']}]->(TheDevilsAdvocate),
(Taylor)-[:DIRECTED {id: 'taylor hackford__DIRECTED__the devil\'s advocate'}]->(TheDevilsAdvocate)

CREATE (AFewGoodMen:Movie {id: "a few good men", title:"A Few Good Men", released: date({year: 1992}), tagline:"In the heart of the nation's capital, in a courthouse of the U.S. government, one man will stop at nothing to keep his honor, and one will stop at nothing to find the truth."})
CREATE (TomC:Person {id: "tom cruise", name: "Tom Cruise", born: date({year: 1962, month: 7, day: 3})})
SET TomC.bornIn = 'Syracuse, New York, USA'
SET TomC.bornPosition = point({latitude: 43.0481, longitude: -76.1474})
CREATE (JackN:Person {id: "jack nicholson", name: "Jack Nicholson", born: date({year: 1937, month: 4, day: 22})})
SET JackN.bornIn = 'Neptune City, New Jersey, USA'
SET JackN.bornPosition = point({latitude: 40.2001, longitude: -74.0332})
CREATE (DemiM:Person {id: "demi moore", name: "Demi Moore", born: date({year: 1962, month: 11, day: 11})})
SET DemiM.bornIn = 'Roswell, New Mexico, USA'
SET DemiM.bornPosition = point({latitude: 33.3943, longitude: -104.5230})
CREATE (KevinB:Person {id: "kevin bacon", name: "Kevin Bacon", born: date({year: 1958, month: 7, day: 8})})
SET KevinB.bornIn = 'Philadelphia, Pennsylvania, USA'
SET KevinB.bornPosition = point({latitude: 39.9526, longitude: -75.1652})
CREATE (KieferS:Person {id: "kiefer sutherland", name: "Kiefer Sutherland", born: date({year: 1966, month: 12, day: 21})})
SET KieferS.bornIn = 'London, England, UK'
SET KieferS.bornPosition = point({latitude: 51.5074, longitude: -0.1278})
CREATE (NoahW:Person {id: "noah wyle", name: "Noah Wyle", born: date({year: 1971, month: 6, day: 4})})
SET NoahW.bornIn = 'Hollywood, California, USA'
SET NoahW.bornPosition = point({latitude: 34.0928, longitude: -118.3287})
CREATE (CubaG:Person {id: "cuba gooding jr.", name: "Cuba Gooding Jr.", born: date({year: 1968, month: 1, day: 2})})
SET CubaG.bornIn = 'The Bronx, New York, USA'
SET CubaG.bornPosition = point({latitude: 40.8448, longitude: -73.8648})
CREATE (KevinP:Person {id: "kevin pollak", name: "Kevin Pollak", born: date({year: 1957, month: 10, day: 30})})
SET KevinP.bornIn = 'San Francisco, California, USA'
SET KevinP.bornPosition = point({latitude: 37.7749, longitude: -122.4194})
CREATE (JTW:Person {id: "j.t. walsh", name: "J.T. Walsh", born: date({year: 1943, month: 9, day: 28})})
SET JTW.bornIn = 'San Francisco, California, USA'
SET JTW.bornPosition = point({latitude: 37.7749, longitude: -122.4194})
CREATE (JamesM:Person {id: "james marshall", name: "James Marshall", born: date({year: 1967, month: 1, day: 2})})
SET JamesM.bornIn = 'Queens, New York, USA'
SET JamesM.bornPosition = point({latitude: 40.7282, longitude: -73.7949})
CREATE (ChristopherG:Person {id: "christopher guest", name: "Christopher Guest", born: date({year: 1948, month: 2, day: 5})})
SET ChristopherG.bornIn = 'New York City, New York, USA'
SET ChristopherG.bornPosition = point({latitude: 40.7128, longitude: -74.0060})
CREATE (RobR:Person {id: "rob reiner", name: "Rob Reiner", born: date({year: 1947, month: 3, day: 6})})
SET RobR.bornIn = 'The Bronx, New York, USA'
SET RobR.bornPosition = point({latitude: 40.8448, longitude: -73.8648})
CREATE (AaronS:Person {id: "aaron sorkin", name: "Aaron Sorkin", born: date({year: 1961, month: 6, day: 9})})
SET AaronS.bornIn = 'New York City, New York, USA'
SET AaronS.bornPosition = point({latitude: 40.7128, longitude: -74.0060})
CREATE
(TomC)-[:ACTED_IN {id:'tom cruise__ACTED_IN__a few good men', roles:['Lt. Daniel Kaffee']}]->(AFewGoodMen),
(JackN)-[:ACTED_IN {id:'jack nicholson__ACTED_IN__a few good men', roles:['Col. Nathan R. Jessup']}]->(AFewGoodMen),
(DemiM)-[:ACTED_IN {id:'demi moore__ACTED_IN__a few good men', roles:['Lt. Cdr. JoAnne Galloway']}]->(AFewGoodMen),
(KevinB)-[:ACTED_IN {id:'kevin bacon__ACTED_IN__a few good men', roles:['Capt. Jack Ross']}]->(AFewGoodMen),
(KieferS)-[:ACTED_IN {id:'kiefer sutherland__ACTED_IN__a few good men', roles:['Lt. Jonathan Kendrick']}]->(AFewGoodMen),
(NoahW)-[:ACTED_IN {id:'noah wyle__ACTED_IN__a few good men', roles:['Cpl. Jeffrey Barnes']}]->(AFewGoodMen),
(CubaG)-[:ACTED_IN {id:'cuba gooding jr.__ACTED_IN__a few good men', roles:['Cpl. Carl Hammaker']}]->(AFewGoodMen),
(KevinP)-[:ACTED_IN {id:'kevin pollak__ACTED_IN__a few good men', roles:['Lt. Sam Weinberg']}]->(AFewGoodMen),
(JTW)-[:ACTED_IN {id:'j.t. walsh__ACTED_IN__a few good men', roles:['Lt. Col. Matthew Andrew Markinson']}]->(AFewGoodMen),
(JamesM)-[:ACTED_IN {id:'james marshall__ACTED_IN__a few good men', roles:['Pfc. Louden Downey']}]->(AFewGoodMen),
(ChristopherG)-[:ACTED_IN {id:'christopher guest__ACTED_IN__a few good men', roles:['Dr. Stone']}]->(AFewGoodMen),
(AaronS)-[:ACTED_IN {id:'aaron sorkin__ACTED_IN__a few good men', roles:['Man in Bar']}]->(AFewGoodMen),
(RobR)-[:DIRECTED {id: 'rob reiner__DIRECTED__a few good men'}]->(AFewGoodMen),
(AaronS)-[:WROTE {id: 'aaron sorkin__WROTE__a few good men'}]->(AFewGoodMen)

CREATE (TopGun:Movie {id: "top gun", title:"Top Gun", released: date({year: 1986}), tagline:'I feel the need, the need for speed.'})
CREATE (KellyM:Person {id: "kelly mcgillis", name: "Kelly McGillis", born: date({year: 1957, month: 7, day: 9})})
SET KellyM.bornIn = 'Newport Beach, California, USA'
SET KellyM.bornPosition = point({latitude: 33.6189, longitude: -117.9298})
CREATE (ValK:Person {id: "val kilmer", name: "Val Kilmer", born: date({year: 1959, month: 12, day: 31})})
SET ValK.bornIn = 'Los Angeles, California, USA'
SET ValK.bornPosition = point({latitude: 34.0522, longitude: -118.2437})
CREATE (AnthonyE:Person {id: "anthony edwards", name: "Anthony Edwards", born: date({year: 1962, month: 7, day: 19})})
SET AnthonyE.bornIn = 'Santa Barbara, California, USA'
SET AnthonyE.bornPosition = point({latitude: 34.4208, longitude: -119.6982})
CREATE (TomS:Person {id: "tom skerritt", name: "Tom Skerritt", born: date({year: 1933, month: 8, day: 25})})
SET TomS.bornIn = 'Detroit, Michigan, USA'
SET TomS.bornPosition = point({latitude: 42.3314, longitude: -83.0458})
CREATE (MegR:Person {id: "meg ryan", name: "Meg Ryan", born: date({year: 1961})})
SET MegR.bornIn = 'Fairfield, Connecticut, USA'
SET MegR.bornPosition = point({latitude: 41.1415, longitude: -73.2637})
CREATE (TonyS:Person {id: "tony scott", name: "Tony Scott", born: date({year: 1944})})
CREATE (JimC:Person {id: "jim cash", name: "Jim Cash", born: date({year: 1941, month: 1, day: 17})})
SET JimC.bornIn = 'Boyne City, Michigan, USA'
SET JimC.bornPosition = point({latitude: 45.2164, longitude: -85.0134})
CREATE
(TomC)-[:ACTED_IN {id:'tom cruise__ACTED_IN__top gun', roles:['Maverick']}]->(TopGun),
(KellyM)-[:ACTED_IN {id:'kelly mcgillis__ACTED_IN__top gun', roles:['Charlie']}]->(TopGun),
(ValK)-[:ACTED_IN {id:'val kilmer__ACTED_IN__top gun', roles:['Iceman']}]->(TopGun),
(AnthonyE)-[:ACTED_IN {id:'anthony edwards__ACTED_IN__top gun', roles:['Goose']}]->(TopGun),
(TomS)-[:ACTED_IN {id:'tom skerritt__ACTED_IN__top gun', roles:['Viper']}]->(TopGun),
(MegR)-[:ACTED_IN {id:'meg ryan__ACTED_IN__top gun', roles:['Carole']}]->(TopGun),
(TonyS)-[:DIRECTED {id: 'tony scott__DIRECTED__top gun'}]->(TopGun),
(JimC)-[:WROTE {id: 'jim cash__WROTE__top gun'}]->(TopGun)

CREATE (JerryMaguire:Movie {id: "jerry maguire", title:"Jerry Maguire", released: date({year: 2000}), tagline:'The rest of his life begins now.'})
CREATE (ReneeZ:Person {id: "renee zellweger", name: "Renée Zellweger", born: date({year: 1969, month: 4, day: 25})})
SET ReneeZ.bornIn = 'Katy, Texas, USA'
SET ReneeZ.bornPosition = point({latitude: 29.7858, longitude: -95.8245})
CREATE (KellyP:Person {id: "kelly preston", name: "Kelly Preston", born: date({year: 1962, month: 10, day: 13})})
SET KellyP.bornIn = 'Honolulu, Hawaii, USA'
SET KellyP.bornPosition = point({latitude: 21.3069, longitude: -157.8583})
CREATE (JerryO:Person {id: "jerry o'connell", name: "Jerry O'Connell", born: date({year: 1974, month: 2, day: 17})})
SET JerryO.bornIn = 'New York City, New York, USA'
SET JerryO.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE (JayM:Person {id: "jay mohr", name: "Jay Mohr", born: date({year: 1970, month: 8, day: 23})})
SET JayM.bornIn = 'Verona, New Jersey, USA'
SET JayM.bornPosition = point({latitude: 40.8298, longitude: -74.2615})

CREATE (BonnieH:Person {id: "bonnie hunt", name: "Bonnie Hunt", born: date({year: 1961, month: 9, day: 22})})
SET BonnieH.bornIn = 'Chicago, Illinois, USA'
SET BonnieH.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE (ReginaK:Person {id: "regina king", name: "Regina King", born: date({year: 1971, month: 1, day: 15})})
SET ReginaK.bornIn = 'Los Angeles, California, USA'
SET ReginaK.bornPosition = point({latitude: 34.0522, longitude: -118.2437})

CREATE (JonathanL:Person {id: "jonathan lipnicki", name: "Jonathan Lipnicki", born: date({year: 1996, month: 10, day: 22})})
SET JonathanL.bornIn = 'Westlake Village, California, USA'
SET JonathanL.bornPosition = point({latitude: 34.1466, longitude: -118.8059})

CREATE (CameronC:Person {id: "cameron crowe", name: "Cameron Crowe", born: date({year: 1957, month: 7, day: 13})})
SET CameronC.bornIn = 'Palm Springs, California, USA'
SET CameronC.bornPosition = point({latitude: 33.8303, longitude: -116.5453})

CREATE
(TomC)-[:ACTED_IN {id:'tom cruise__ACTED_IN__jerry maguire', roles:['Jerry Maguire']}]->(JerryMaguire),
(CubaG)-[:ACTED_IN {id:'cuba gooding jr.__ACTED_IN__jerry maguire', roles:['Rod Tidwell']}]->(JerryMaguire),
(ReneeZ)-[:ACTED_IN {id:'renee zellweger__ACTED_IN__jerry maguire', roles:['Dorothy Boyd']}]->(JerryMaguire),
(KellyP)-[:ACTED_IN {id:'kelly preston__ACTED_IN__jerry maguire', roles:['Avery Bishop']}]->(JerryMaguire),
(JerryO)-[:ACTED_IN {id:'jerry o\'connell__ACTED_IN__jerry maguire', roles:['Frank Cushman']}]->(JerryMaguire),
(JayM)-[:ACTED_IN {id:'jay mohr__ACTED_IN__jerry maguire', roles:['Bob Sugar']}]->(JerryMaguire),
(BonnieH)-[:ACTED_IN {id:'bonnie hunt__ACTED_IN__jerry maguire', roles:['Laurel Boyd']}]->(JerryMaguire),
(ReginaK)-[:ACTED_IN {id:'regina king__ACTED_IN__jerry maguire', roles:['Marcee Tidwell']}]->(JerryMaguire),
(JonathanL)-[:ACTED_IN {id:'jonathan lipnicki__ACTED_IN__jerry maguire', roles:['Ray Boyd']}]->(JerryMaguire),
(CameronC)-[:DIRECTED {id: 'cameron crowe__DIRECTED__jerry maguire'}]->(JerryMaguire),
(CameronC)-[:PRODUCED {id: 'cameron crowe__PRODUCED__jerry maguire'}]->(JerryMaguire),
(CameronC)-[:WROTE {id: 'cameron crowe__WROTE__jerry maguire'}]->(JerryMaguire)

CREATE (StandByMe:Movie {id: "stand by me", title:"Stand By Me", released: date({year: 1986}), tagline:"For some, it's the last real taste of innocence, and the first real taste of life. But for everyone, it's the time that memories are made of."})
CREATE (RiverP:Person {id: "river phoenix", name: "River Phoenix", born: date({year: 1970, month: 8, day: 23})})
SET RiverP.bornIn = 'Madras, Oregon, USA'
SET RiverP.bornPosition = point({latitude: 44.6332, longitude: -121.1291})

CREATE (CoreyF:Person {id: "corey feldman", name: "Corey Feldman", born: date({year: 1971, month: 7, day: 16})})
SET CoreyF.bornIn = 'Reseda, California, USA'
SET CoreyF.bornPosition = point({latitude: 34.2011, longitude: -118.5367})

CREATE (WilW:Person {id: "wil wheaton", name: "Wil Wheaton", born: date({year: 1972, month: 7, day: 29})})
SET WilW.bornIn = 'Burbank, California, USA'
SET WilW.bornPosition = point({latitude: 34.1808, longitude: -118.3089})

CREATE (JohnC:Person {id: "john cusack", name: "John Cusack", born: date({year: 1966, month: 6, day: 28})})
SET JohnC.bornIn = 'Evanston, Illinois, USA'
SET JohnC.bornPosition = point({latitude: 42.0451, longitude: -87.6877})

CREATE (MarshallB:Person {id: "marshall bell", name: "Marshall Bell", born: date({year: 1942, month: 9, day: 28})})
SET MarshallB.bornIn = 'Tulsa, Oklahoma, USA'
SET MarshallB.bornPosition = point({latitude: 36.1539, longitude: -95.9928})

CREATE
(WilW)-[:ACTED_IN {id:'wil wheaton__ACTED_IN__stand by me', roles:['Gordie Lachance']}]->(StandByMe),
(RiverP)-[:ACTED_IN {id:'river phoenix__ACTED_IN__stand by me', roles:['Chris Chambers']}]->(StandByMe),
(JerryO)-[:ACTED_IN {id:'jerry o\'connell__ACTED_IN__stand by me', roles:['Vern Tessio']}]->(StandByMe),
(CoreyF)-[:ACTED_IN {id:'corey feldman__ACTED_IN__stand by me', roles:['Teddy Duchamp']}]->(StandByMe),
(JohnC)-[:ACTED_IN {id:'john cusack__ACTED_IN__stand by me', roles:['Denny Lachance']}]->(StandByMe),
(KieferS)-[:ACTED_IN {id:'kiefer sutherland__ACTED_IN__stand by me', roles:['Ace Merrill']}]->(StandByMe),
(MarshallB)-[:ACTED_IN {id:'marshall bell__ACTED_IN__stand by me', roles:['Mr. Lachance']}]->(StandByMe),
(RobR)-[:DIRECTED {id: 'rob reiner__DIRECTED__stand by me'}]->(StandByMe)

CREATE (AsGoodAsItGets:Movie {id: "as good as it gets", title:"As Good as It Gets", released: date({year: 1997}), tagline:'A comedy from the heart that goes for the throat.'})
CREATE (HelenH:Person {id: "helen hunt", name: "Helen Hunt", born: date({year: 1963, month: 6, day: 15})})
SET HelenH.bornIn = 'Culver City, California, USA'
SET HelenH.bornPosition = point({latitude: 34.0219, longitude: -118.3965})

CREATE (GregK:Person {id: "greg kinnear", name: "Greg Kinnear", born: date({year: 1963, month: 6, day: 17})})
SET GregK.bornIn = 'Logansport, Indiana, USA'
SET GregK.bornPosition = point({latitude: 40.7545, longitude: -86.3567})

CREATE (JamesB:Person {id: "james l. brooks", name: "James L. Brooks", born: date({year: 1940, month: 5, day: 9})})
SET JamesB.bornIn = 'Brooklyn, New York, USA'
SET JamesB.bornPosition = point({latitude: 40.6782, longitude: -73.9442})

CREATE
(JackN)-[:ACTED_IN {id:'jack nicholson__ACTED_IN__as good as it gets', roles:['Melvin Udall']}]->(AsGoodAsItGets),
(HelenH)-[:ACTED_IN {id:'helen hunt__ACTED_IN__as good as it gets', roles:['Carol Connelly']}]->(AsGoodAsItGets),
(GregK)-[:ACTED_IN {id:'greg kinnear__ACTED_IN__as good as it gets', roles:['Simon Bishop']}]->(AsGoodAsItGets),
(CubaG)-[:ACTED_IN {id:'cuba gooding jr.__ACTED_IN__as good as it gets', roles:['Frank Sachs']}]->(AsGoodAsItGets),
(JamesB)-[:DIRECTED {id: 'james l. brooks__DIRECTED__as good as it gets'}]->(AsGoodAsItGets)

CREATE (WhatDreamsMayCome:Movie {id: "what dreams may come", title:"What Dreams May Come", released: date({year: 1998}), tagline:'After life there is more. The end is just the beginning.'})
CREATE (AnnabellaS:Person {id: "annabella sciorra", name: "Annabella Sciorra", born: date({year: 1960, month: 3, day: 29})})
SET AnnabellaS.bornIn = 'Brooklyn, New York, USA'
SET AnnabellaS.bornPosition = point({latitude: 40.6782, longitude: -73.9442})

CREATE (MaxS:Person {id: "max von sydow", name: "Max von Sydow", born: date({year: 1929, month: 4, day: 10})})
SET MaxS.bornIn = 'Lund, Sweden'
SET MaxS.bornPosition = point({latitude: 55.7047, longitude: 13.1910})

CREATE (WernerH:Person {id: "werner herzog", name: "Werner Herzog", born: date({year: 1942, month: 9, day: 5})})
SET WernerH.bornIn = 'Munich, Germany'
SET WernerH.bornPosition = point({latitude: 48.1351, longitude: 11.5820})

CREATE (Robin:Person {id: "robin williams", name: "Robin Williams", born: date({year: 1951, month: 7, day: 21})})
SET Robin.bornIn = 'Chicago, Illinois, USA'
SET Robin.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE (VincentW:Person {id: "vincent ward", name: "Vincent Ward", born: date({year: 1956, month: 2, day: 16})})
SET VincentW.bornIn = 'Greytown, New Zealand'
SET VincentW.bornPosition = point({latitude: -41.0817, longitude: 175.4604})

CREATE
(Robin)-[:ACTED_IN {id:'robin williams__ACTED_IN__what dreams may come', roles:['Chris Nielsen']}]->(WhatDreamsMayCome),
(CubaG)-[:ACTED_IN {id:'cuba gooding jr.__ACTED_IN__what dreams may come', roles:['Albert Lewis']}]->(WhatDreamsMayCome),
(AnnabellaS)-[:ACTED_IN {id:'annabella sciorra__ACTED_IN__what dreams may come', roles:['Annie Collins-Nielsen']}]->(WhatDreamsMayCome),
(MaxS)-[:ACTED_IN {id:'max von sydow__ACTED_IN__what dreams may come', roles:['The Tracker']}]->(WhatDreamsMayCome),
(WernerH)-[:ACTED_IN {id:'werner herzog__ACTED_IN__what dreams may come', roles:['The Face']}]->(WhatDreamsMayCome),
(VincentW)-[:DIRECTED {id: 'vincent ward__DIRECTED__what dreams may come'}]->(WhatDreamsMayCome)

CREATE (SnowFallingonCedars:Movie {id: "snow falling on cedars", title:"Snow Falling on Cedars", released: date({year: 1999}), tagline:'First loves last. Forever.'})
CREATE (EthanH:Person {id: "ethan hawke", name: "Ethan Hawke", born: date({year: 1970, month: 11, day: 6})})
SET EthanH.bornIn = 'Austin, Texas, USA'
SET EthanH.bornPosition = point({latitude: 30.2672, longitude: -97.7431})

CREATE (RickY:Person {id: "rick yune", name: "Rick Yune", born: date({year: 1971, month: 8, day: 22})})
SET RickY.bornIn = 'Washington, D.C., USA'
SET RickY.bornPosition = point({latitude: 38.9072, longitude: -77.0369})

CREATE (JamesC:Person {id: "james cromwell", name: "James Cromwell", born: date({year: 1940, month: 1, day: 27})})
SET JamesC.bornIn = 'Los Angeles, California, USA'
SET JamesC.bornPosition = point({latitude: 34.0522, longitude: -118.2437})

CREATE (ScottH:Person {id: "scott hicks", name: "Scott Hicks", born: date({year: 1953, month: 3, day: 4})})
SET ScottH.bornIn = 'Uganda'
SET ScottH.bornPosition = point({latitude: 1.3733, longitude: 32.2903})

CREATE
(EthanH)-[:ACTED_IN {id:'ethan hawke__ACTED_IN__snow falling on cedars', roles:['Ishmael Chambers']}]->(SnowFallingonCedars),
(RickY)-[:ACTED_IN {id:'rick yune__ACTED_IN__snow falling on cedars', roles:['Kazuo Miyamoto']}]->(SnowFallingonCedars),
(MaxS)-[:ACTED_IN {id:'max von sydow__ACTED_IN__snow falling on cedars', roles:['Nels Gudmundsson']}]->(SnowFallingonCedars),
(JamesC)-[:ACTED_IN {id:'james cromwell__ACTED_IN__snow falling on cedars', roles:['Judge Fielding']}]->(SnowFallingonCedars),
(ScottH)-[:DIRECTED {id: 'scott hicks__DIRECTED__snow falling on cedars'}]->(SnowFallingonCedars)

CREATE (YouveGotMail:Movie {id: "you've got mail", title:"You've Got Mail", released: date({year: 1998}), tagline:'At odds in life... in love on-line.'})
CREATE (ParkerP:Person {id: "parker posey", name: "Parker Posey", born: date({year: 1968, month: 11, day: 8})})
SET ParkerP.bornIn = 'Baltimore, Maryland, USA'
SET ParkerP.bornPosition = point({latitude: 39.2904, longitude: -76.6122})

CREATE (DaveC:Person {id: "dave chappelle", name: "Dave Chappelle", born: date({year: 1973, month: 8, day: 24})})
SET DaveC.bornIn = 'Washington, D.C., USA'
SET DaveC.bornPosition = point({latitude: 38.9072, longitude: -77.0369})

CREATE (SteveZ:Person {id: "steve zahn", name: "Steve Zahn", born: date({year: 1967, month: 11, day: 13})})
SET SteveZ.bornIn = 'Marshall, Minnesota, USA'
SET SteveZ.bornPosition = point({latitude: 44.4469, longitude: -95.7884})

CREATE (TomH:Person {id: "tom hanks", name: "Tom Hanks", born: date({year: 1956, month: 7, day: 9})})
SET TomH.bornIn = 'Concord, California, USA'
SET TomH.bornPosition = point({latitude: 37.9775, longitude: -122.0311})

CREATE (NoraE:Person {id: "nora ephron", name: "Nora Ephron", born: date({year: 1941, month: 5, day: 19})})
SET NoraE.bornIn = 'New York City, New York, USA'
SET NoraE.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__you\'ve got mail', roles:['Joe Fox']}]->(YouveGotMail),
(MegR)-[:ACTED_IN {id:'meg ryan__ACTED_IN__you\'ve got mail', roles:['Kathleen Kelly']}]->(YouveGotMail),
(GregK)-[:ACTED_IN {id:'greg kinnear__ACTED_IN__you\'ve got mail', roles:['Frank Navasky']}]->(YouveGotMail),
(ParkerP)-[:ACTED_IN {id:'parker posey__ACTED_IN__you\'ve got mail', roles:['Patricia Eden']}]->(YouveGotMail),
(DaveC)-[:ACTED_IN {id:'dave chappelle__ACTED_IN__you\'ve got mail', roles:['Kevin Jackson']}]->(YouveGotMail),
(SteveZ)-[:ACTED_IN {id:'steve zahn__ACTED_IN__you\'ve got mail', roles:['George Pappas']}]->(YouveGotMail),
(NoraE)-[:DIRECTED {id: 'nora ephron__DIRECTED__you\'ve got mail'}]->(YouveGotMail)

CREATE (SleeplessInSeattle:Movie {id: "sleepless in seattle", title:"Sleepless in Seattle", released: date({year: 1993}), tagline:'What if someone you never met, someone you never saw, someone you never knew was the only someone for you?'})
CREATE (RitaW:Person {id: "rita wilson", name: "Rita Wilson", born: date({year: 1956, month: 10, day: 26})})
SET RitaW.bornIn = 'Los Angeles, California, USA'
SET RitaW.bornPosition = point({latitude: 34.0522, longitude: -118.2437})

CREATE (BillPull:Person {id: "bill pullman", name: "Bill Pullman", born: date({year: 1953, month: 12, day: 17})})
SET BillPull.bornIn = 'Hornell, New York, USA'
SET BillPull.bornPosition = point({latitude: 42.3276, longitude: -77.6617})

CREATE (VictorG:Person {id: "victor garber", name: "Victor Garber", born: date({year: 1949, month: 3, day: 16})})
SET VictorG.bornIn = 'London, Ontario, Canada'
SET VictorG.bornPosition = point({latitude: 42.9849, longitude: -81.2453})

CREATE (RosieO:Person {id: "rosie o'donnell", name: "Rosie O'Donnell", born: date({year: 1962, month: 3, day: 21})})
SET RosieO.bornIn = 'Commack, New York, USA'
SET RosieO.bornPosition = point({latitude: 40.8420, longitude: -73.2929})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__sleepless in seattle', roles:['Sam Baldwin']}]->(SleeplessInSeattle),
(MegR)-[:ACTED_IN {id:'meg ryan__ACTED_IN__sleepless in seattle', roles:['Annie Reed']}]->(SleeplessInSeattle),
(RitaW)-[:ACTED_IN {id:'rita wilson__ACTED_IN__sleepless in seattle', roles:['Suzy']}]->(SleeplessInSeattle),
(BillPull)-[:ACTED_IN {id:'bill pullman__ACTED_IN__sleepless in seattle', roles:['Walter']}]->(SleeplessInSeattle),
(VictorG)-[:ACTED_IN {id:'victor garber__ACTED_IN__sleepless in seattle', roles:['Greg']}]->(SleeplessInSeattle),
(RosieO)-[:ACTED_IN {id:'rosie o\'donnell__ACTED_IN__sleepless in seattle', roles:['Becky']}]->(SleeplessInSeattle),
(NoraE)-[:DIRECTED {id: 'nora ephron__DIRECTED__sleepless in seattle'}]->(SleeplessInSeattle)

CREATE (JoeVersustheVolcano:Movie {id: "joe versus the volcano", title:"Joe Versus the Volcano", released: date({year: 1990}), tagline:'A story of love, lava and burning desire.'})
CREATE (JohnS:Person {id: "john patrick stanley", name: "John Patrick Shanley", born: date({year: 1950, month: 10, day: 3})})
SET JohnS.bornIn = 'New York City, New York, USA'
SET JohnS.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE (Nathan:Person {id: "nathan lane", name: "Nathan Lane", born: date({year: 1956, month: 2, day: 3})})
SET Nathan.bornIn = 'Jersey City, New Jersey, USA'
SET Nathan.bornPosition = point({latitude: 40.7178, longitude: -74.0431})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__joe versus the volcano', roles:['Joe Banks']}]->(JoeVersustheVolcano),
(MegR)-[:ACTED_IN {id:'meg ryan__ACTED_IN__joe versus the volcano', roles:['DeDe', 'Angelica Graynamore', 'Patricia Graynamore']}]->(JoeVersustheVolcano),
(Nathan)-[:ACTED_IN {id:'nathan lane__ACTED_IN__joe versus the volcano', roles:['Baw']}]->(JoeVersustheVolcano),
(JohnS)-[:DIRECTED {id: 'john patrick stanley__DIRECTED__joe versus the volcano'}]->(JoeVersustheVolcano)

CREATE (WhenHarryMetSally:Movie {id: "when harry met sally", title:"When Harry Met Sally", released: date({year: 1998}), tagline:'Can two friends sleep together and still love each other in the morning?'})
CREATE (BillyC:Person {id: "billy crystal", name: "Billy Crystal", born: date({year: 1948, month: 3, day: 14})})
SET BillyC.bornIn = 'New York City, New York, USA'
SET BillyC.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE (CarrieF:Person {id: "carrie fisher", name: "Carrie Fisher", born: date({year: 1956, month: 10, day: 21})})
SET CarrieF.bornIn = 'Burbank, California, USA'
SET CarrieF.bornPosition = point({latitude: 34.1808, longitude: -118.3089})

CREATE (BrunoK:Person {id: "bruno kirby", name: "Bruno Kirby", born: date({year: 1949, month: 4, day: 28})})
SET BrunoK.bornIn = 'New York City, New York, USA'
SET BrunoK.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE
(BillyC)-[:ACTED_IN {id:'billy crystal__ACTED_IN__when harry met sally', roles:['Harry Burns']}]->(WhenHarryMetSally),
(MegR)-[:ACTED_IN {id:'meg ryan__ACTED_IN__when harry met sally', roles:['Sally Albright']}]->(WhenHarryMetSally),
(CarrieF)-[:ACTED_IN {id:'carrie fisher__ACTED_IN__when harry met sally', roles:['Marie']}]->(WhenHarryMetSally),
(BrunoK)-[:ACTED_IN {id:'bruno kirby__ACTED_IN__when harry met sally', roles:['Jess']}]->(WhenHarryMetSally),
(RobR)-[:DIRECTED {id: 'rob reiner__DIRECTED__when harry met sally'}]->(WhenHarryMetSally),
(RobR)-[:PRODUCED {id: 'rob reiner__PRODUCED__when harry met sally'}]->(WhenHarryMetSally),
(NoraE)-[:PRODUCED {id: 'nora ephron__PRODUCED__when harry met sally'}]->(WhenHarryMetSally),
(NoraE)-[:WROTE {id: 'nora ephron__WROTE__when harry met sally'}]->(WhenHarryMetSally)

CREATE (ThatThingYouDo:Movie {id: "that thing you do", title:"That Thing You Do", released: date({year: 1996}), tagline:'In every life there comes a time when that thing you dream becomes that thing you do'})
CREATE (LivT:Person {id: "liv tyler", name: "Liv Tyler", born: date({year: 1977, month: 7, day: 1})})
SET LivT.bornIn = 'New York City, New York, USA'
SET LivT.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__that thing you do', roles:['Mr. White']}]->(ThatThingYouDo),
(LivT)-[:ACTED_IN {id:'liv tyler__ACTED_IN__that thing you do', roles:['Faye Dolan']}]->(ThatThingYouDo),
(Charlize)-[:ACTED_IN {id:'charlize theron__ACTED_IN__that thing you do', roles:['Tina']}]->(ThatThingYouDo),
(TomH)-[:DIRECTED {id: 'tom hanks__DIRECTED__that thing you do'}]->(ThatThingYouDo)

CREATE (TheReplacements:Movie {id: "the replacements", title:"The Replacements", released: date({year: 2000}), tagline:'Pain heals, Chicks dig scars... Glory lasts forever'})
CREATE (Brooke:Person {id: "brooke langton", name: "Brooke Langton", born: date({year: 1970, month: 11, day: 27})})
SET Brooke.bornIn = 'Arizona, USA'
SET Brooke.bornPosition = point({latitude: 34.0489, longitude: -111.0937})

CREATE (Gene:Person {id: "gene hackman", name: "Gene Hackman", born: date({year: 1930, month: 1, day: 30})})
SET Gene.bornIn = 'San Bernardino, California, USA'
SET Gene.bornPosition = point({latitude: 34.1083, longitude: -117.2898})

CREATE (Orlando:Person {id: "orlando jones", name: "Orlando Jones", born: date({year: 1968, month: 4, day: 10})})
SET Orlando.bornIn = 'Mobile, Alabama, USA'
SET Orlando.bornPosition = point({latitude: 30.6954, longitude: -88.0399})

CREATE (Howard:Person {id: "howard deutch", name: "Howard Deutch", born: date({year: 1950, month: 9, day: 14})})
SET Howard.bornIn = 'New York City, New York, USA'
SET Howard.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__the replacements', roles:['Shane Falco']}]->(TheReplacements),
(Brooke)-[:ACTED_IN {id:'brooke langton__ACTED_IN__the replacements', roles:['Annabelle Farrell']}]->(TheReplacements),
(Gene)-[:ACTED_IN {id:'gene hackman__ACTED_IN__the replacements', roles:['Jimmy McGinty']}]->(TheReplacements),
(Orlando)-[:ACTED_IN {id:'orlando jones__ACTED_IN__the replacements', roles:['Clifford Franklin']}]->(TheReplacements),
(Howard)-[:DIRECTED {id: 'howard deutch__DIRECTED__the replacements'}]->(TheReplacements)

CREATE (RescueDawn:Movie {id: "rescuedawn", title:"RescueDawn", released: date({year: 2006}), tagline:"Based on the extraordinary true story of one man's fight for freedom"})
CREATE (ChristianB:Person {id: "christian bale", name: "Christian Bale", born: date({year: 1974, month: 1, day: 30})})
SET ChristianB.bornIn = 'Haverfordwest, Wales, UK'
SET ChristianB.bornPosition = point({latitude: 51.8016, longitude: -4.9695})

CREATE (ZachG:Person {id: "zach grenier", name: "Zach Grenier", born: date({year: 1954, month: 2, day: 12})})
SET ZachG.bornIn = 'Englewood, New Jersey, USA'
SET ZachG.bornPosition = point({latitude: 40.8929, longitude: -73.9726})

CREATE
(MarshallB)-[:ACTED_IN {id:'marshall bell__ACTED_IN__rescuedawn', roles:['Admiral']}]->(RescueDawn),
(ChristianB)-[:ACTED_IN {id:'christian bale__ACTED_IN__rescuedawn', roles:['Dieter Dengler']}]->(RescueDawn),
(ZachG)-[:ACTED_IN {id:'zach grenier__ACTED_IN__rescuedawn', roles:['Squad Leader']}]->(RescueDawn),
(SteveZ)-[:ACTED_IN {id:'steve zahn__ACTED_IN__rescuedawn', roles:['Duane']}]->(RescueDawn),
(WernerH)-[:DIRECTED {id: 'werner herzog__DIRECTED__rescuedawn'}]->(RescueDawn)

CREATE (TheBirdcage:Movie {id: "the birdcage", title:"The Birdcage", released: date({year: 1996}), tagline:'Come as you are'})
CREATE (MikeN:Person {id: "mike nichols", name: "Mike Nichols", born: date({year: 1931, month: 11, day: 6})})
SET MikeN.bornIn = 'Berlin, Germany'
SET MikeN.bornPosition = point({latitude: 52.5200, longitude: 13.4050})

CREATE
(Robin)-[:ACTED_IN {id:'robin williams__ACTED_IN__the birdcage', roles:['Armand Goldman']}]->(TheBirdcage),
(Nathan)-[:ACTED_IN {id:'nathan lane__ACTED_IN__the birdcage', roles:['Albert Goldman']}]->(TheBirdcage),
(Gene)-[:ACTED_IN {id:'gene hackman__ACTED_IN__the birdcage', roles:['Sen. Kevin Keeley']}]->(TheBirdcage),
(MikeN)-[:DIRECTED {id: 'mike nichols__DIRECTED__the birdcage'}]->(TheBirdcage)

CREATE (Unforgiven:Movie {id: "unforgiven", title:"Unforgiven", released: date({year: 1992}), tagline:"It's a hell of a thing, killing a man"})
CREATE (RichardH:Person {id: "richard harris", name: "Richard Harris", born: date({year: 1930, month: 10, day: 1})})
SET RichardH.bornIn = 'Limerick, Ireland'
SET RichardH.bornPosition = point({latitude: 52.6638, longitude: -8.6267})

CREATE (ClintE:Person {id: "clint eastwood", name: "Clint Eastwood", born: date({year: 1930, month: 5, day: 31})})
SET ClintE.bornIn = 'San Francisco, California, USA'
SET ClintE.bornPosition = point({latitude: 37.7749, longitude: -122.4194})

CREATE
(RichardH)-[:ACTED_IN {id:'richard harris__ACTED_IN__unforgiven', roles:['English Bob']}]->(Unforgiven),
(ClintE)-[:ACTED_IN {id:'clint eastwood__ACTED_IN__unforgiven', roles:['Bill Munny']}]->(Unforgiven),
(Gene)-[:ACTED_IN {id:'gene hackman__ACTED_IN__unforgiven', roles:['Little Bill Daggett']}]->(Unforgiven),
(ClintE)-[:DIRECTED {id: 'clint eastwood__DIRECTED__unforgiven'}]->(Unforgiven)

CREATE (JohnnyMnemonic:Movie {id: "johnny mnemonic", title:"Johnny Mnemonic", released: date({year: 1995}), tagline:'The hottest data on earth. In the coolest head in town'})
CREATE (Takeshi:Person {id: "takeshi kitano", name: "Takeshi Kitano", born: date({year: 1947, month: 1, day: 18})})
SET Takeshi.bornIn = 'Tokyo, Japan'
SET Takeshi.bornPosition = point({latitude: 35.6895, longitude: 139.6917})

CREATE (Dina:Person {id: "dina meyer", name: "Dina Meyer", born: date({year: 1968, month: 12, day: 22})})
SET Dina.bornIn = 'Queens, New York, USA'
SET Dina.bornPosition = point({latitude: 40.7282, longitude: -73.7949})

CREATE (IceT:Person {id: "ice-t", name: "Ice-T", born: date({year: 1958, month: 2, day: 16})})
SET IceT.bornIn = 'Newark, New Jersey, USA'
SET IceT.bornPosition = point({latitude: 40.7357, longitude: -74.1724})

CREATE (RobertL:Person {id: "robert longo", name: "Robert Longo", born: date({year: 1953, month: 1, day: 7})})
SET RobertL.bornIn = 'Brooklyn, New York, USA'
SET RobertL.bornPosition = point({latitude: 40.6782, longitude: -73.9442})

CREATE
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__johnny mnemonic', roles:['Johnny Mnemonic']}]->(JohnnyMnemonic),
(Takeshi)-[:ACTED_IN {id:'takeshi kitano__ACTED_IN__johnny mnemonic', roles:['Takahashi']}]->(JohnnyMnemonic),
(Dina)-[:ACTED_IN {id:'dina meyer__ACTED_IN__johnny mnemonic', roles:['Jane']}]->(JohnnyMnemonic),
(IceT)-[:ACTED_IN {id:'ice-t__ACTED_IN__johnny mnemonic', roles:['J-Bone']}]->(JohnnyMnemonic),
(RobertL)-[:DIRECTED {id: 'robert longo__DIRECTED__johnny mnemonic'}]->(JohnnyMnemonic)

CREATE (CloudAtlas:Movie {id: "cloud atlas", title:"Cloud Atlas", released: date({year: 2012}), tagline:'Everything is connected'})
CREATE (HalleB:Person {id: "halle berry", name: "Halle Berry", born: date({year: 1966, month: 8, day: 14})})
SET HalleB.bornIn = 'Cleveland, Ohio, USA'
SET HalleB.bornPosition = point({latitude: 41.4993, longitude: -81.6944})

CREATE (JimB:Person {id: "jim broadbent", name: "Jim Broadbent", born: date({year: 1949, month: 5, day: 24})})
SET JimB.bornIn = 'Lincoln, Lincolnshire, England, UK'
SET JimB.bornPosition = point({latitude: 53.2307, longitude: -0.5406})

CREATE (TomT:Person {id: "tom tykwer", name: "Tom Tykwer", born: date({year: 1965, month: 5, day: 23})})
SET TomT.bornIn = 'Wuppertal, Germany'
SET TomT.bornPosition = point({latitude: 51.2562, longitude: 7.1508})

CREATE (DavidMitchell:Person {id: "david mitchell", name: "David Mitchell", born: date({year: 1969, month: 1, day: 12})})
SET DavidMitchell.bornIn = 'Southport, England, UK'
SET DavidMitchell.bornPosition = point({latitude: 53.6478, longitude: -3.0083})

CREATE (StefanArndt:Person {id: "stefan arndt", name: "Stefan Arndt", born: date({year: 1961, month: 8, day: 28})})
SET StefanArndt.bornIn = 'Munich, Germany'
SET StefanArndt.bornPosition = point({latitude: 48.1351, longitude: 11.5820})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__cloud atlas', roles:['Zachry', 'Dr. Henry Goose', 'Isaac Sachs', 'Dermot Hoggins']}]->(CloudAtlas),
(Hugo)-[:ACTED_IN {id:'hugo weaving__ACTED_IN__cloud atlas', roles:['Bill Smoke', 'Haskell Moore', 'Tadeusz Kesselring', 'Nurse Noakes', 'Boardman Mephi', 'Old Georgie']}]->(CloudAtlas),
(HalleB)-[:ACTED_IN {id:'halle berry__ACTED_IN__cloud atlas', roles:['Luisa Rey', 'Jocasta Ayrs', 'Ovid', 'Meronym']}]->(CloudAtlas),
(JimB)-[:ACTED_IN {id:'jim broadbent__ACTED_IN__cloud atlas', roles:['Vyvyan Ayrs', 'Captain Molyneux', 'Timothy Cavendish']}]->(CloudAtlas),
(TomT)-[:DIRECTED {id: 'tom tykwer__DIRECTED__cloud atlas'}]->(CloudAtlas),
(LillyW)-[:DIRECTED {id: 'lilly wachowski__DIRECTED__cloud atlas'}]->(CloudAtlas),
(LanaW)-[:DIRECTED {id: 'lana wachowski__DIRECTED__cloud atlas'}]->(CloudAtlas),
(DavidMitchell)-[:WROTE {id: 'david mitchell__WROTE__cloud atlas'}]->(CloudAtlas),
(StefanArndt)-[:PRODUCED {id: 'stefan arndt__PRODUCED__cloud atlas'}]->(CloudAtlas)

CREATE (TheDaVinciCode:Movie {id: "the da vinci code", title:"The Da Vinci Code", released: date({year: 2006}), tagline:'Break The Codes'})
CREATE (IanM:Person {id: "ian mckellen", name: "Ian McKellen", born: date({year: 1939, month: 5, day: 25})})
SET IanM.bornIn = 'Burnley, Lancashire, England, UK'
SET IanM.bornPosition = point({latitude: 53.7893, longitude: -2.2405})

CREATE (AudreyT:Person {id: "audrey tautou", name: "Audrey Tautou", born: date({year: 1976, month: 8, day: 9})})
SET AudreyT.bornIn = 'Beaumont, Puy-de-Dôme, France'
SET AudreyT.bornPosition = point({latitude: 45.7238, longitude: 3.1126})

CREATE (PaulB:Person {id: "paul bettany", name: "Paul Bettany", born: date({year: 1971, month: 5, day: 27})})
SET PaulB.bornIn = 'London, England, UK'
SET PaulB.bornPosition = point({latitude: 51.5074, longitude: -0.1278})

CREATE (RonH:Person {id: "ron howard", name: "Ron Howard", born: date({year: 1954, month: 3, day: 1})})
SET RonH.bornIn = 'Duncan, Oklahoma, USA'
SET RonH.bornPosition = point({latitude: 34.5023, longitude: -97.9578})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__the da vinci code', roles:['Dr. Robert Langdon']}]->(TheDaVinciCode),
(IanM)-[:ACTED_IN {id:'ian mckellen__ACTED_IN__the da vinci code', roles:['Sir Leight Teabing']}]->(TheDaVinciCode),
(AudreyT)-[:ACTED_IN {id:'audrey tautou__ACTED_IN__the da vinci code', roles:['Sophie Neveu']}]->(TheDaVinciCode),
(PaulB)-[:ACTED_IN {id:'paul bettany__ACTED_IN__the da vinci code', roles:['Silas']}]->(TheDaVinciCode),
(RonH)-[:DIRECTED {id: 'ron howard__DIRECTED__the da vinci code'}]->(TheDaVinciCode)

CREATE (VforVendetta:Movie {id: "v for vendetta", title:"V for Vendetta", released: date({year: 2006}), tagline:'Freedom! Forever!'})
CREATE (NatalieP:Person {id: "natalie portman", name: "Natalie Portman", born: date({year: 1981, month: 6, day: 9})})
SET NatalieP.bornIn = 'Jerusalem, Israel'
SET NatalieP.bornPosition = point({latitude: 31.7683, longitude: 35.2137})

CREATE (StephenR:Person {id: "stephen rea", name: "Stephen Rea", born: date({year: 1946, month: 10, day: 31})})
SET StephenR.bornIn = 'Belfast, Northern Ireland, UK'
SET StephenR.bornPosition = point({latitude: 54.5973, longitude: -5.9301})

CREATE (JohnH:Person {id: "john hurt", name: "John Hurt", born: date({year: 1940, month: 1, day: 22})})
SET JohnH.bornIn = 'Chesterfield, Derbyshire, England, UK'
SET JohnH.bornPosition = point({latitude: 53.2350, longitude: -1.4216})

CREATE (BenM:Person {id: "ben miles", name: "Ben Miles", born: date({year: 1967, month: 9, day: 29})})
SET BenM.bornIn = 'Wimbledon, London, England, UK'
SET BenM.bornPosition = point({latitude: 51.4215, longitude: -0.2087})

CREATE
(Hugo)-[:ACTED_IN {id:'hugo weaving__ACTED_IN__v for vendetta', roles:['V']}]->(VforVendetta),
(NatalieP)-[:ACTED_IN {id:'natalie portman__ACTED_IN__v for vendetta', roles:['Evey Hammond']}]->(VforVendetta),
(StephenR)-[:ACTED_IN {id:'stephen rea__ACTED_IN__v for vendetta', roles:['Eric Finch']}]->(VforVendetta),
(JohnH)-[:ACTED_IN {id:'john hurt__ACTED_IN__v for vendetta', roles:['High Chancellor Adam Sutler']}]->(VforVendetta),
(BenM)-[:ACTED_IN {id:'ben miles__ACTED_IN__v for vendetta', roles:['Dascomb']}]->(VforVendetta),
(JamesM)-[:DIRECTED {id: 'james marshall__DIRECTED__v for vendetta'}]->(VforVendetta),
(LillyW)-[:PRODUCED {id: 'lilly wachowski__PRODUCED__v for vendetta'}]->(VforVendetta),
(LanaW)-[:PRODUCED {id: 'lana wachowski__PRODUCED__v for vendetta'}]->(VforVendetta),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__v for vendetta'}]->(VforVendetta),
(LillyW)-[:WROTE {id: 'lilly wachowski__WROTE__v for vendetta'}]->(VforVendetta),
(LanaW)-[:WROTE {id: 'lana wachowski__WROTE__v for vendetta'}]->(VforVendetta)

CREATE (SpeedRacer:Movie {id: "speed racer", title:"Speed Racer", released: date({year: 2008}), tagline:'Speed has no limits'})
CREATE (EmileH:Person {id: "emile hirsch", name: "Emile Hirsch", born: date({year: 1985, month: 3, day: 13})})
SET EmileH.bornIn = 'Topanga, California, USA'
SET EmileH.bornPosition = point({latitude: 34.0914, longitude: -118.6026})

CREATE (JohnG:Person {id: "john goodman", name: "John Goodman", born: date({year: 1960, month: 6, day: 20})})
SET JohnG.bornIn = 'St. Louis, Missouri, USA'
SET JohnG.bornPosition = point({latitude: 38.6270, longitude: -90.1994})

CREATE (SusanS:Person {id: "susan sarandon", name: "Susan Sarandon", born: date({year: 1946, month: 10, day: 4})})
SET SusanS.bornIn = 'New York City, New York, USA'
SET SusanS.bornPosition = point({latitude: 40.7128, longitude: -74.0060})

CREATE (MatthewF:Person {id: "matthew fox", name: "Matthew Fox", born: date({year: 1966, month: 7, day: 14})})
SET MatthewF.bornIn = 'Abington, Pennsylvania, USA'
SET MatthewF.bornPosition = point({latitude: 40.1204, longitude: -75.1186})

CREATE (ChristinaR:Person {id: "christina ricci", name: "Christina Ricci", born: date({year: 1980, month: 2, day: 12})})
SET ChristinaR.bornIn = 'Santa Monica, California, USA'
SET ChristinaR.bornPosition = point({latitude: 34.0195, longitude: -118.4912})

CREATE (Rain:Person {id: "rain", name: "Rain", born: date({year: 1982, month: 6, day: 25})})
SET Rain.bornIn = 'Seoul, South Korea'
SET Rain.bornPosition = point({latitude: 37.5665, longitude: 126.9780})

CREATE
(EmileH)-[:ACTED_IN {id:'emile hirsch__ACTED_IN__speed racer', roles:['Speed Racer']}]->(SpeedRacer),
(JohnG)-[:ACTED_IN {id:'john goodman__ACTED_IN__speed racer', roles:['Pops']}]->(SpeedRacer),
(SusanS)-[:ACTED_IN {id:'susan sarandon__ACTED_IN__speed racer', roles:['Mom']}]->(SpeedRacer),
(MatthewF)-[:ACTED_IN {id:'matthew fox__ACTED_IN__speed racer', roles:['Racer X']}]->(SpeedRacer),
(ChristinaR)-[:ACTED_IN {id:'christina ricci__ACTED_IN__speed racer', roles:['Trixie']}]->(SpeedRacer),
(Rain)-[:ACTED_IN {id:'rain__ACTED_IN__speed racer', roles:['Taejo Togokahn']}]->(SpeedRacer),
(BenM)-[:ACTED_IN {id:'ben miles__ACTED_IN__speed racer', roles:['Cass Jones']}]->(SpeedRacer),
(LillyW)-[:DIRECTED {id: 'lilly wachowski__DIRECTED__speed racer'}]->(SpeedRacer),
(LanaW)-[:DIRECTED {id: 'lana wachowski__DIRECTED__speed racer'}]->(SpeedRacer),
(LillyW)-[:WROTE {id: 'lilly wachowski__WROTE__speed racer'}]->(SpeedRacer),
(LanaW)-[:WROTE {id: 'lana wachowski__WROTE__speed racer'}]->(SpeedRacer),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__speed racer'}]->(SpeedRacer)

CREATE (NinjaAssassin:Movie {id: "ninja assassin", title:"Ninja Assassin", released: date({year: 2009}), tagline:'Prepare to enter a secret world of assassins'})
CREATE (NaomieH:Person {id: "naomie harris", name: "Naomie Harris", born: date({year: 1976, month: 9, day: 6})})
SET NaomieH.bornIn = 'London, England, UK'
SET NaomieH.bornPosition = point({latitude: 51.5074, longitude: -0.1278})

CREATE
(Rain)-[:ACTED_IN {id:'rain__ACTED_IN__ninja assassin', roles:['Raizo']}]->(NinjaAssassin),
(NaomieH)-[:ACTED_IN {id:'naomie harris__ACTED_IN__ninja assassin', roles:['Mika Coretti']}]->(NinjaAssassin),
(RickY)-[:ACTED_IN {id:'rick yune__ACTED_IN__ninja assassin', roles:['Takeshi']}]->(NinjaAssassin),
(BenM)-[:ACTED_IN {id:'ben miles__ACTED_IN__ninja assassin', roles:['Ryan Maslow']}]->(NinjaAssassin),
(JamesM)-[:DIRECTED {id: 'james marshall__DIRECTED__ninja assassin'}]->(NinjaAssassin),
(LillyW)-[:PRODUCED {id: 'lilly wachowski__PRODUCED__ninja assassin'}]->(NinjaAssassin),
(LanaW)-[:PRODUCED {id: 'lana wachowski__PRODUCED__ninja assassin'}]->(NinjaAssassin),
(JoelS)-[:PRODUCED {id: 'joel silver__PRODUCED__ninja assassin'}]->(NinjaAssassin)

CREATE (TheGreenMile:Movie {id: "the green mile", title:"The Green Mile", released: date({year: 1999}), tagline:"Walk a mile you'll never forget."})
CREATE (MichaelD:Person {id: "michael clarke duncan", name: "Michael Clarke Duncan", born: date({year: 1957, month: 12, day: 10})})
SET MichaelD.bornIn = 'Chicago, Illinois, USA'
SET MichaelD.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE (DavidM:Person {id: "david morse", name: "David Morse", born: date({year: 1953, month: 10, day: 11})})
SET DavidM.bornIn = 'Beverly, Massachusetts, USA'
SET DavidM.bornPosition = point({latitude: 42.5584, longitude: -70.8800})

CREATE (SamR:Person {id: "sam rockwell", name: "Sam Rockwell", born: date({year: 1968, month: 11, day: 5})})
SET SamR.bornIn = 'Daly City, California, USA'
SET SamR.bornPosition = point({latitude: 37.6879, longitude: -122.4702})

CREATE (GaryS:Person {id: "gary sinise", name: "Gary Sinise", born: date({year: 1955, month: 3, day: 17})})
SET GaryS.bornIn = 'Blue Island, Illinois, USA'
SET GaryS.bornPosition = point({latitude: 41.6575, longitude: -87.6801})

CREATE (PatriciaC:Person {id: "patricia clarkson", name: "Patricia Clarkson", born: date({year: 1959, month: 12, day: 29})})
SET PatriciaC.bornIn = 'New Orleans, Louisiana, USA'
SET PatriciaC.bornPosition = point({latitude: 29.9511, longitude: -90.0715})

CREATE (FrankD:Person {id: "frank darabont", name: "Frank Darabont", born: date({year: 1959, month: 1, day: 28})})
SET FrankD.bornIn = 'Montbéliard, Doubs, France'
SET FrankD.bornPosition = point({latitude: 47.5107, longitude: 6.7977})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__the green mile', roles:['Paul Edgecomb']}]->(TheGreenMile),
(MichaelD)-[:ACTED_IN {id:'michael clarke duncan__ACTED_IN__the green mile', roles:['John Coffey']}]->(TheGreenMile),
(DavidM)-[:ACTED_IN {id:'david morse__ACTED_IN__the green mile', roles:['Brutus "Brutal" Howell']}]->(TheGreenMile),
(BonnieH)-[:ACTED_IN {id:'bonnie hunt__ACTED_IN__the green mile', roles:['Jan Edgecomb']}]->(TheGreenMile),
(JamesC)-[:ACTED_IN {id:'james cromwell__ACTED_IN__the green mile', roles:['Warden Hal Moores']}]->(TheGreenMile),
(SamR)-[:ACTED_IN {id:'sam rockwell__ACTED_IN__the green mile', roles:['"Wild Bill" Wharton']}]->(TheGreenMile),
(GaryS)-[:ACTED_IN {id:'gary sinise__ACTED_IN__the green mile', roles:['Burt Hammersmith']}]->(TheGreenMile),
(PatriciaC)-[:ACTED_IN {id:'patricia clarkson__ACTED_IN__the green mile', roles:['Melinda Moores']}]->(TheGreenMile),
(FrankD)-[:DIRECTED {id: 'frank darabont__DIRECTED__the green mile'}]->(TheGreenMile)

CREATE (FrostNixon:Movie {id: "frost/nixon", title:"Frost/Nixon", released: date({year: 2008}), tagline:'400 million people were waiting for the truth.'})
CREATE (FrankL:Person {id: "frank langella", name: "Frank Langella", born: date({year: 1938, month: 1, day: 1})})
SET FrankL.bornIn = 'Bayonne, New Jersey, USA'
SET FrankL.bornPosition = point({latitude: 40.6687, longitude: -74.1143})

CREATE (MichaelS:Person {id: "michael sheen", name: "Michael Sheen", born: date({year: 1969, month: 2, day: 5})})
SET MichaelS.bornIn = 'Newport, Wales, UK'
SET MichaelS.bornPosition = point({latitude: 51.5842, longitude: -2.9977})

CREATE (OliverP:Person {id: "oliver platt", name: "Oliver Platt", born: date({year: 1960, month: 1, day: 12})})
SET OliverP.bornIn = 'Windsor, Ontario, Canada'
SET OliverP.bornPosition = point({latitude: 42.3149, longitude: -83.0364})

CREATE
(FrankL)-[:ACTED_IN {id:'frank langella__ACTED_IN__frost/nixon', roles:['Richard Nixon']}]->(FrostNixon),
(MichaelS)-[:ACTED_IN {id:'michael sheen__ACTED_IN__frost/nixon', roles:['David Frost']}]->(FrostNixon),
(KevinB)-[:ACTED_IN {id:'kevin bacon__ACTED_IN__frost/nixon', roles:['Jack Brennan']}]->(FrostNixon),
(OliverP)-[:ACTED_IN {id:'oliver platt__ACTED_IN__frost/nixon', roles:['Bob Zelnick']}]->(FrostNixon),
(SamR)-[:ACTED_IN {id:'sam rockwell__ACTED_IN__frost/nixon', roles:['James Reston, Jr.']}]->(FrostNixon),
(RonH)-[:DIRECTED {id: 'ron howard__DIRECTED__frost/nixon'}]->(FrostNixon)

CREATE (Hoffa:Movie {id: "hoffa", title:"Hoffa", released: date({year: 1992}), tagline:"He didn't want law. He wanted justice."})
CREATE (DannyD:Person {id: "danny devito", name: "Danny DeVito", born: date({year: 1944, month: 11, day: 17})})
SET DannyD.bornIn = 'Neptune Township, New Jersey, USA'
SET DannyD.bornPosition = point({latitude: 40.2112, longitude: -74.0379})

CREATE (JohnR:Person {id: "john c. reilly", name: "John C. Reilly", born: date({year: 1965, month: 5, day: 24})})
SET JohnR.bornIn = 'Chicago, Illinois, USA'
SET JohnR.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE
(JackN)-[:ACTED_IN {id:'jack nicholson__ACTED_IN__hoffa', roles:['Hoffa']}]->(Hoffa),
(DannyD)-[:ACTED_IN {id:'danny devito__ACTED_IN__hoffa', roles:['Robert "Bobby" Ciaro']}]->(Hoffa),
(JTW)-[:ACTED_IN {id:'j.t. walsh__ACTED_IN__hoffa', roles:['Frank Fitzsimmons']}]->(Hoffa),
(JohnR)-[:ACTED_IN {id:'john c. reilly__ACTED_IN__hoffa', roles:['Peter "Pete" Connelly']}]->(Hoffa),
(DannyD)-[:DIRECTED {id: 'danny devito__DIRECTED__hoffa'}]->(Hoffa)

CREATE (Apollo13:Movie {id: "apollo 13", title:"Apollo 13", released: date({year: 1995}), tagline:'Houston, we have a problem.'})
CREATE (EdH:Person {id: "ed harris", name: "Ed Harris", born: date({year: 1950, month: 11, day: 28})})
SET EdH.bornIn = 'Englewood, New Jersey, USA'
SET EdH.bornPosition = point({latitude: 40.8929, longitude: -73.9726})

CREATE (BillPax:Person {id: "bill paxton", name: "Bill Paxton", born: date({year: 1955, month: 5, day: 17})})
SET BillPax.bornIn = 'Fort Worth, Texas, USA'
SET BillPax.bornPosition = point({latitude: 32.7555, longitude: -97.3308})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__apollo 13', roles:['Jim Lovell']}]->(Apollo13),
(KevinB)-[:ACTED_IN {id:'kevin bacon__ACTED_IN__apollo 13', roles:['Jack Swigert']}]->(Apollo13),
(EdH)-[:ACTED_IN {id:'ed harris__ACTED_IN__apollo 13', roles:['Gene Kranz']}]->(Apollo13),
(BillPax)-[:ACTED_IN {id:'bill paxton__ACTED_IN__apollo 13', roles:['Fred Haise']}]->(Apollo13),
(GaryS)-[:ACTED_IN {id:'gary sinise__ACTED_IN__apollo 13', roles:['Ken Mattingly']}]->(Apollo13),
(RonH)-[:DIRECTED {id: 'ron howard__DIRECTED__apollo 13'}]->(Apollo13)

CREATE (Twister:Movie {id: "twister", title:"Twister", released: date({year: 1996}), tagline:"Don't Breathe. Don't Look Back."})
CREATE (PhilipH:Person {id: "philip seymour hoffman", name: "Philip Seymour Hoffman", born: date({year: 1967, month: 7, day: 23})})
SET PhilipH.bornIn = 'Fairport, New York, USA'
SET PhilipH.bornPosition = point({latitude: 43.0987, longitude: -77.4417})

CREATE (JanB:Person {id: "jan de bont", name: "Jan de Bont", born: date({year: 1943, month: 10, day: 22})})
SET JanB.bornIn = 'Eindhoven, Netherlands'
SET JanB.bornPosition = point({latitude: 51.4416, longitude: 5.4697})

CREATE
(BillPax)-[:ACTED_IN {id:'bill paxton__ACTED_IN__twister', roles:['Bill Harding']}]->(Twister),
(HelenH)-[:ACTED_IN {id:'helen hunt__ACTED_IN__twister', roles:['Dr. Jo Harding']}]->(Twister),
(ZachG)-[:ACTED_IN {id:'zach grenier__ACTED_IN__twister', roles:['Eddie']}]->(Twister),
(PhilipH)-[:ACTED_IN {id:'philip seymour hoffman__ACTED_IN__twister', roles:['Dustin "Dusty" Davis']}]->(Twister),
(JanB)-[:DIRECTED {id: 'jan de bont__DIRECTED__twister'}]->(Twister)

CREATE (CastAway:Movie {id: "cast away", title:"Cast Away", released: date({year: 2000}), tagline:'At the edge of the world, his journey begins.'})
CREATE (RobertZ:Person {id: "robert zemeckis", name: "Robert Zemeckis", born: date({year: 1951, month: 5, day: 14})})
SET RobertZ.bornIn = 'Chicago, Illinois, USA'
SET RobertZ.bornPosition = point({latitude: 41.8781, longitude: -87.6298})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__cast away', roles:['Chuck Noland']}]->(CastAway),
(HelenH)-[:ACTED_IN {id:'helen hunt__ACTED_IN__cast away', roles:['Kelly Frears']}]->(CastAway),
(RobertZ)-[:DIRECTED {id: 'robert zemeckis__DIRECTED__cast away'}]->(CastAway)

CREATE (OneFlewOvertheCuckoosNest:Movie {id: "one flew over the cuckoo's nest", title:"One Flew Over the Cuckoo's Nest", released: date({year: 1975}), tagline:"If he's crazy, what does that make you?"})
CREATE (MilosF:Person {id: "milos forman", name: "Milos Forman", born: date({year: 1932, month: 2, day: 18})})
SET MilosF.bornIn = 'Čáslav, Czechoslovakia'
SET MilosF.bornPosition = point({latitude: 49.9102, longitude: 15.3915})

CREATE
(JackN)-[:ACTED_IN {id:'jack nicholson__ACTED_IN__one flew over the cuckoo\'s nest', roles:['Randle McMurphy']}]->(OneFlewOvertheCuckoosNest),
(DannyD)-[:ACTED_IN {id:'danny devito__ACTED_IN__one flew over the cuckoo\'s nest', roles:['Martini']}]->(OneFlewOvertheCuckoosNest),
(MilosF)-[:DIRECTED {id: 'milos forman__DIRECTED__one flew over the cuckoo\'s nest'}]->(OneFlewOvertheCuckoosNest)

CREATE (SomethingsGottaGive:Movie {id: "something's gotta give", title:"Something's Gotta Give", released: date({year: 2003})})
CREATE (DianeK:Person {id: "diane keaton", name: "Diane Keaton", born: date({year: 1946, month: 1, day: 5})})
SET DianeK.bornIn = 'Los Angeles, California, USA'
SET DianeK.bornPosition = point({latitude: 34.0522, longitude: -118.2437})

CREATE (NancyM:Person {id: "nancy meyers", name: "Nancy Meyers", born: date({year: 1949, month: 12, day: 8})})
SET NancyM.bornIn = 'Philadelphia, Pennsylvania, USA'
SET NancyM.bornPosition = point({latitude: 39.9526, longitude: -75.1652})

CREATE
(JackN)-[:ACTED_IN {id:'jack nicholson__ACTED_IN__something\'s gotta give', roles:['Harry Sanborn']}]->(SomethingsGottaGive),
(DianeK)-[:ACTED_IN {id:'diane keaton__ACTED_IN__something\'s gotta give', roles:['Erica Barry']}]->(SomethingsGottaGive),
(Keanu)-[:ACTED_IN {id:'keanu reeves__ACTED_IN__something\'s gotta give', roles:['Julian Mercer']}]->(SomethingsGottaGive),
(NancyM)-[:DIRECTED {id: 'nancy meyers__DIRECTED__something\'s gotta give'}]->(SomethingsGottaGive),
(NancyM)-[:PRODUCED {id: 'nancy meyers__PRODUCED__something\'s gotta give'}]->(SomethingsGottaGive),
(NancyM)-[:WROTE {id: 'nancy meyers__WROTE__something\'s gotta give'}]->(SomethingsGottaGive)

CREATE (BicentennialMan:Movie {id: "bicentennial man", title:"Bicentennial Man", released: date({year: 1999}), tagline:"One robot's 200 year journey to become an ordinary man."})
CREATE (ChrisC:Person {id: "chris columbus", name: "Chris Columbus", born: date({year: 1958, month: 9, day: 10})})
SET ChrisC.bornIn = 'Spangler, Pennsylvania, USA'
SET ChrisC.bornPosition = point({latitude: 40.6401, longitude: -78.7753})

CREATE
(Robin)-[:ACTED_IN {id:'robin williams__ACTED_IN__bicentennial man', roles:['Andrew Marin']}]->(BicentennialMan),
(OliverP)-[:ACTED_IN {id:'oliver platt__ACTED_IN__bicentennial man', roles:['Rupert Burns']}]->(BicentennialMan),
(ChrisC)-[:DIRECTED {id: 'chris columbus__DIRECTED__bicentennial man'}]->(BicentennialMan)

CREATE (CharlieWilsonsWar:Movie {id: "charlie wilson's war", title:"Charlie Wilson's War", released: date({year: 2007}), tagline:"A stiff drink. A little mascara. A lot of nerve. Who said they couldn't bring down the Soviet empire."})
CREATE (JuliaR:Person {id: "julia roberts", name: "Julia Roberts", born: date({year: 1967, month: 10, day: 28})})
SET JuliaR.bornIn = 'Smyrna, Georgia, USA'
SET JuliaR.bornPosition = point({latitude: 33.8837, longitude: -84.5144})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__charlie wilson\'s war', roles:['Rep. Charlie Wilson']}]->(CharlieWilsonsWar),
(JuliaR)-[:ACTED_IN {id:'julia roberts__ACTED_IN__charlie wilson\'s war', roles:['Joanne Herring']}]->(CharlieWilsonsWar),
(PhilipH)-[:ACTED_IN {id:'philip seymour hoffman__ACTED_IN__charlie wilson\'s war', roles:['Gust Avrakotos']}]->(CharlieWilsonsWar),
(MikeN)-[:DIRECTED {id: 'mike nichols__DIRECTED__charlie wilson\'s war'}]->(CharlieWilsonsWar)

CREATE (ThePolarExpress:Movie {id: "the polar express", title:"The Polar Express", released: date({year: 2004}), tagline:'This Holiday Season... Believe'})
CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__the polar express', roles:['Hero Boy', 'Father', 'Conductor', 'Hobo', 'Scrooge', 'Santa Claus']}]->(ThePolarExpress),
(RobertZ)-[:DIRECTED {id: 'robert zemeckis__DIRECTED__the polar express'}]->(ThePolarExpress)

CREATE (ALeagueofTheirOwn:Movie {id: "a league of their own", title:"A League of Their Own", released: date({year: 1992}), tagline:'Once in a lifetime you get a chance to do something different.'})
CREATE (Madonna:Person {id: "madonna", name: "Madonna", born: date({year: 1958, month: 8, day: 16})})
SET Madonna.bornIn = 'Bay City, Michigan, USA'
SET Madonna.bornPosition = point({latitude: 43.5945, longitude: -83.8889})

CREATE (GeenaD:Person {id: "geena davis", name: "Geena Davis", born: date({year: 1956, month: 1, day: 21})})
SET GeenaD.bornIn = 'Wareham, Massachusetts, USA'
SET GeenaD.bornPosition = point({latitude: 41.7618, longitude: -70.7195})

CREATE (LoriP:Person {id: "lori petty", name: "Lori Petty", born: date({year: 1963, month: 10, day: 14})})
SET LoriP.bornIn = 'Chattanooga, Tennessee, USA'
SET LoriP.bornPosition = point({latitude: 35.0456, longitude: -85.3097})

CREATE (PennyM:Person {id: "penny marshall", name: "Penny Marshall", born: date({year: 1943, month: 10, day: 15})})
SET PennyM.bornIn = 'The Bronx, New York, USA'
SET PennyM.bornPosition = point({latitude: 40.8448, longitude: -73.8648})

CREATE
(TomH)-[:ACTED_IN {id:'tom hanks__ACTED_IN__a league of their own', roles:['Jimmy Dugan']}]->(ALeagueofTheirOwn),
(GeenaD)-[:ACTED_IN {id:'geena davis__ACTED_IN__a league of their own', roles:['Dottie Hinson']}]->(ALeagueofTheirOwn),
(LoriP)-[:ACTED_IN {id:'lori petty__ACTED_IN__a league of their own', roles:['Kit Keller']}]->(ALeagueofTheirOwn),
(RosieO)-[:ACTED_IN {id:'rosie o\'donnell__ACTED_IN__a league of their own', roles:['Doris Murphy']}]->(ALeagueofTheirOwn),
(Madonna)-[:ACTED_IN {id:'madonna__ACTED_IN__a league of their own', roles:['"All the Way" Mae Mordabito']}]->(ALeagueofTheirOwn),
(BillPax)-[:ACTED_IN {id:'bill paxton__ACTED_IN__a league of their own', roles:['Bob Hinson']}]->(ALeagueofTheirOwn),
(PennyM)-[:DIRECTED {id: 'penny marshall__DIRECTED__a league of their own'}]->(ALeagueofTheirOwn)

CREATE (PaulBlythe:Person {id: "paul blythe", name: "Paul Blythe"})
CREATE (AngelaScope:Person {id: "angela scope", name: "Angela Scope"})
CREATE (JessicaThompson:Person {id: "jessica thompson", name: "Jessica Thompson"})
CREATE (JamesThompson:Person {id: "james thompson", name: "James Thompson"})

CREATE
(JamesThompson)-[:FOLLOWS {id: 'james thompson__FOLLOWS__jessica thompson'}]->(JessicaThompson),
(AngelaScope)-[:FOLLOWS {id: 'angela scope__FOLLOWS__jessica thompson'}]->(JessicaThompson),
(PaulBlythe)-[:FOLLOWS {id: 'paul blythe__FOLLOWS__angela scope'}]->(AngelaScope)

CREATE
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__cloud atlas', summary:'An amazing journey', rating:95}]->(CloudAtlas),
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__the replacements', summary:'Silly, but fun', rating:65}]->(TheReplacements),
(JamesThompson)-[:REVIEWED {id:'james thompson__REVIEWED__the replacements', summary:'The coolest football movie ever', rating:100}]->(TheReplacements),
(AngelaScope)-[:REVIEWED {id:'angela scope__REVIEWED__the replacements', summary:'Pretty funny at times', rating:62}]->(TheReplacements),
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__unforgiven', summary:'Dark, but compelling', rating:85}]->(Unforgiven),
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__the birdcage', summary:"Slapstick redeemed only by the Robin Williams and Gene Hackman's stellar performances", rating:45}]->(TheBirdcage),
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__the da vinci code', summary:'A solid romp', rating:68}]->(TheDaVinciCode),
(JamesThompson)-[:REVIEWED {id:'james thompson__REVIEWED__the da vinci code', summary:'Fun, but a little far fetched', rating:65}]->(TheDaVinciCode),
(JessicaThompson)-[:REVIEWED {id:'jessica thompson__REVIEWED__jerry maguire', summary:'You had me at Jerry', rating:92}]->(JerryMaguire)

WITH TomH as a
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d) RETURN a,m,d LIMIT 10;
