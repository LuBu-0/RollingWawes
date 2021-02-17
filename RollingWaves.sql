DROP TABLE IF EXISTS Sede CASCADE;
DROP TABLE IF EXISTS Magazzino CASCADE;
DROP TABLE IF EXISTS Dipendente CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS Ordine CASCADE;
DROP TABLE IF EXISTS Operazioni_Magazzino CASCADE;
DROP TABLE IF EXISTS Fornitore CASCADE;
DROP TABLE IF EXISTS Merce CASCADE;
DROP TABLE IF EXISTS Esecuzione_Operazioni_Magazzino CASCADE;
DROP TABLE IF EXISTS Composizione_Ordine CASCADE;
DROP TABLE IF EXISTS Carrello CASCADE;
DROP TABLE IF EXISTS Consegna CASCADE;
DROP TABLE IF EXISTS Deposito CASCADE;
DROP TABLE IF EXISTS Merce_prenotata CASCADE;
DROP TABLE IF EXISTS Rifornimento_Merce CASCADE;
DROP TABLE IF EXISTS Stipendio CASCADE;
DROP TABLE IF EXISTS Fattura CASCADE;
DROP TABLE IF EXISTS Incasso CASCADE;

--CREAZIONE TABELLE
CREATE TABLE Sede
(
  ID char (4) primary key,
  via varchar (60) not null,
  citta varchar (25) not null,
  email varchar (50) not null,
  telefono varchar(12) not null,
  direttore char (6)  --chiave esterna rimandata a dopo creazione tabella Dipendente.
);

CREATE TABLE Magazzino
(
  ID char (4) primary key,
  via varchar (60) not null,
  citta varchar (25) not null,
  gestore char (4) REFERENCES Sede(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Dipendente
(
  matricola char(6) primary key,
  nome varchar (15),
  cognome varchar(15),
  eta int check (eta > 15 and eta < 120),
  stipendio float not null,
  impiego varchar(15) not null,
  sedeAssunzione char(4) REFERENCES Sede(ID) ON DELETE SET NULL ON UPDATE CASCADE,
  sedeAfferita char(4) REFERENCES Sede(ID) ON DELETE SET NULL ON UPDATE CASCADE,
  magazzinoAfferito char(4) REFERENCES magazzino(ID) ON DELETE SET NULL ON UPDATE CASCADE
);

ALTER TABLE Sede
ADD FOREIGN KEY (direttore)
REFERENCES Dipendente(matricola) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE Cliente
(
  username varchar(10) primary key,
  nome varchar(15),
  cognome varchar(15),
  saldoPunti int check (saldoPunti >= 0),
  via varchar(60) not null,
  cap varchar(10) not null,
  citta varchar(25) not null,
  metodoPagamento varchar(50)
);

CREATE TABLE Ordine
(
  numeroOrdine char(11) primary key,
  totale float not null check (totale > 0),
  partenza char(4)  REFERENCES Magazzino(ID) ON DELETE NO ACTION ON UPDATE CASCADE,
  destinazione varchar (10)  references Cliente(username) ON DELETE NO ACTION ON UPDATE CASCADE,
  gestito_da_sede char(4) REFERENCES Sede(ID) ON DELETE NO ACTION ON UPDATE CASCADE,
  tracking varchar(12) not null,
  annullato bool default false not null,
  data date not null
);

CREATE TABLE Operazioni_Magazzino
(
  dataOra timestamp,
  magazzino char(4) REFERENCES Magazzino(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  operazione varchar(7) not null,
  primary key(dataOra, magazzino)
);

CREATE TABLE Fornitore
(
  partitaIVA char(11) primary key,
  nome varchar (20) not null,
  email varchar (50) not null,
  telefono varchar(12)
);

CREATE TABLE Merce
(
  ID char(5) primary key,
  tipo varchar (15) not null,
  marca varchar(20),
  taglia varchar(6) not null,
  prezzo float not null
);

CREATE TABLE Esecuzione_Operazioni_Magazzino
(
  magazzino char(4) REFERENCES Magazzino(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  dipendente char(6) REFERENCES Dipendente(matricola) ON DELETE CASCADE ON UPDATE CASCADE,
  dataOra timestamp not null,
  primary key(magazzino, dipendente,dataOra)
);

CREATE TABLE Composizione_Ordine
(
  ordine char(11) REFERENCES Ordine(numeroOrdine) ON DELETE CASCADE ON UPDATE CASCADE,
  prodotto char(5) REFERENCES Merce(ID) ON DELETE NO ACTION ON UPDATE CASCADE,
  quantita int not null default 1 check (quantita > 0),
  primary key(ordine, prodotto)
);

CREATE TABLE Carrello
(
  cliente varchar(10) REFERENCES Cliente(username) ON DELETE CASCADE ON UPDATE CASCADE,
  merce char(5) references Merce(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  quantita int not null check (quantita > 0),
  primary key (cliente, merce)
);

CREATE TABLE Consegna
(
  dipendente char(6) REFERENCES Dipendente(matricola) ON DELETE NO ACTION ON UPDATE CASCADE,
  cliente varchar(10) REFERENCES Cliente(username) ON DELETE NO ACTION ON UPDATE CASCADE,
  dataOra timestamp not null,
  primary key (dipendente, cliente, dataOra)
);

CREATE TABLE Deposito
(
  prodotto char(5) REFERENCES Merce(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  magazzino char(4) REFERENCES Magazzino(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  quantita int not null check (quantita >= 0),
  primary key (prodotto, magazzino)
);

CREATE TABLE Merce_prenotata
(
  sede char(4) REFERENCES Sede(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  fornitore char(11) REFERENCES Fornitore(partitaIVA) ON DELETE NO ACTION ON UPDATE CASCADE,
  prodotto char(5) REFERENCES Merce(ID) ON DELETE NO ACTION ON UPDATE CASCADE,
  quantita int not null,
  data date not null,
  PRIMARY KEY(sede,fornitore, prodotto, data)
);

CREATE TABLE Rifornimento_Merce
(
  magazzino char(4) REFERENCES Magazzino(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  fornitore char(11) REFERENCES Fornitore(partitaIVA) ON DELETE NO ACTION ON UPDATE CASCADE,
  prodotto char(5) REFERENCES Merce(ID) ON DELETE NO ACTION ON UPDATE CASCADE,
  quantita int not null check(quantita > 0),
  data date not null,
  primary key(magazzino, prodotto, fornitore, data)
);

CREATE TABLE Stipendio
(
  ID char(12) primary key,
  importo float not null,
  data date not null,
  destinatario char(6)  REFERENCES Dipendente(matricola) ON DELETE NO ACTION ON UPDATE CASCADE,
  trasmittente char(4)  REFERENCES Sede(ID) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE Fattura
(
  ID char(12) primary key,
  importo float not null,
  data date not null,
  destinatario char(11)  REFERENCES Fornitore(partitaIVA) ON DELETE NO ACTION ON UPDATE CASCADE,
  trasmittente char(4)  REFERENCES Sede(ID) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Incasso
(
  ID char(12) primary key,
  importo float not null,
  data date not null,
  trasmittente varchar(10)  REFERENCES Cliente(username) ON DELETE NO ACTION ON UPDATE CASCADE,
  destinatario char(4)  REFERENCES Sede(ID) ON DELETE NO ACTION ON UPDATE CASCADE
);

--POPOLAMENTO TABELLE
ALTER TABLE Sede DISABLE TRIGGER ALL ; --causa chiave esterna magazzino
INSERT INTO Sede VALUES
  ('LA01', '101 S Olive street', 'Los Angeles', 'RollingWavesLA@gmail.com', '7176686023', '000025'),
  ('NY01', '45 William street', 'New York', 'RollingWavesNY@gmail.com', '4433015687', '000048'),
  ('BO01', '55 Adams street', 'Boston', 'RollingWavesBO@gmail.com', '7171214569', '000051'),
  ('TO01', '15 Valley road', 'Toronto', 'RollingWavesTO@gmail.com', '24982136547', '000014'),
  ('MI01', 'via Alessandro Manzoni 61', 'Milano', 'RollingWavesMI@gmail.com', '3934567890', '000099'),
  ('CT01', 'via don Luigi Sturzo 97', 'Catania', 'RollingWavesCT@gmail.com', '3331875693', '000689'),
  ('PA01', '54 rue de Montessuy', 'Parigi', 'RollingWavesPA@gmail.com', '149270050', '000061'),
  ('BE01', 'Leipziger Pl. 12', 'Berlino', 'RollingWavesBE@gmail.com', '3020621770', '000753'),
  ('BA01', 'plaça de Catalunya 23', 'Barcellona', 'RollingWavesBA@gmail.com', '936194570', '000023'),
  ('AM01', 'Utrechtsestraat 14', 'Amsterdam', 'RollingWavesAM@gmail.com', '204893929', '002777'),
  ('LO01', '63 Robert street', 'Londra', 'RollingWavesLO@gmail.com', '2079318811', '003568');
ALTER TABLE Sede ENABLE TRIGGER ALL ;

INSERT INTO Magazzino VALUES
  ('US01','112 Chatsworth street','Los Angeles','LA01'),
  ('US02','256 Farmers boulevard','New York','NY01'),
  ('US03', '118 W 28th street', 'Chicago', 'NY01'),
  ('US04','12 Burton street','Boston','BO01'),
  ('CA01','156 Tapscott road','Toronto','TO01'),
  ('IT01','via Pescara 111','Milano','MI01'),
  ('IT02','via Colle della Lite 12','Roma','MI01'),
  ('IT03','via del Bergamotto 55','Catania','CT01'),
  ('FR01','16 Rue Navier ','Parigi','PA01'),
  ('FR02','255 rue Pierre Valdo','Lione','PA01'),
  ('DE01','Bienenweg 12','Berlino','BE01'),
  ('DE02','Eichenauer Str. 45','Monaco','BE01'),
  ('ES01','Carrer del callego 15','Barcellona','BA01'),
  ('ES02','calle de Colombia 17','Madrid','BA01'),
  ('NL01','Pieter Postsingel 74','Amsterdam','AM01'),
  ('UK01','12 Chestnut ave','Londra','LO01'),
  ('UK02','18 Wardley Hall road','Manchester','LO01');

INSERT INTO Dipendente VALUES
  ('000025', 'John', 'Everitt', 36, 3206.27, 'direttore', 'LA01', 'LA01',NULL ),
  ('000048', 'Luke', 'Sampson', 58, 3127.56, 'direttore', 'NY01', 'NY01',NULL ),
  ('000051', 'Lazaro', 'Manning', 28, 3206.27, 'direttore', 'NY01', 'BO01',NULL ),
  ('000014', 'Edgar', 'Bates', 33, 3127.56, 'direttore', 'LA01', 'TO01',NULL ),
  ('000099', 'Mario', 'Rossi', 27, 3057.86, 'direttore', 'MI01', 'MI01',NULL ),
  ('000689', 'Aldo', 'Mori', 40, 3057.86, 'direttore', 'CT01', 'CT01',NULL ),
  ('000061', 'Leal', 'Rochon', 31, 3206.27, 'direttore', 'PA01', 'PA01',NULL ),
  ('000753', 'Bastian', 'Schweinsteiger', 23, 3057.86, 'direttore', 'BE01', 'BE01',NULL ),
  ('000023', 'Lucas', 'Vasquez', 60, 3127.56, 'direttore', 'BA01', 'BA01',NULL ),
  ('002777', 'Luigi', 'Bianchi', 43, 3057.86, 'direttore', 'CT01', 'AM01',NULL ),
  ('003568', 'Ashley', 'Young', 28, 3057.86, 'direttore', 'LO01', 'LO01',NULL ),
  ('467374', 'Daniel', 'Smallwood', 17, 1482.12, 'impiegato', 'BO01', 'BO01',NULL ),
  ('718299', 'Bruce', 'Campana', 19, 1482.12, 'impiegato', 'TO01', 'TO01',NULL ),
  ('006954', 'Tomas', 'Wayne', 43, 1482.12, 'impiegato', 'LA01', 'LA01',NULL ),
  ('418439', 'Francesco', 'Verdi', 53, 1350.17, 'impiegato', 'MI01', 'MI01',NULL ),
  ('250972', 'Stan', 'Smith', 20, 1482.12, 'impiegato', 'NY01', 'LA01',NULL ),
  ('283721', 'Matteo', 'Rossi', 32, 1350.17, 'impiegato', 'MI01', 'MI01',NULL ),
  ('260172', 'Fiacre', 'Pedalue', 40, 1386.74, 'impiegato', 'PA01', 'PA01',NULL ),
  ('082050', 'Denise', 'Godoi', 23, 1388.20, 'impiegato', 'BA01', 'BA01',NULL ),
  ('268262', 'Lydyan', 'Zomers', 50, 1360.17, 'impiegato', 'AM01', 'AM01',NULL ),
  ('710799', 'John', 'Cena', 47, 1482.12, 'impiegato', 'NY01', 'NY01',NULL ),
  ('261084', 'Giuseppe', 'Esposito', 33, 1350.17, 'impiegato', 'CT01', 'CT01',NULL ),
  ('970673', 'Edward', 'Cullen', 22, 1374.12, 'impiegato', 'LO01', 'LO01',NULL ),
  ('536881', 'Jose', 'Alvarez', 45, 1388.20, 'impiegato', 'BA01', 'BA01',NULL ),
  ('766306', 'Marcus', 'Bread', 23, 1374.12, 'impiegato', 'LO01', 'LO01',NULL ),
  ('472838', 'Jean', 'Marier', 29, 1386.74, 'impiegato', 'PA01', 'PA01',NULL ),
  ('294757', 'Peter', 'Griffin', 60, 1482.12, 'impiegato', 'NY01', 'BO01',NULL ),
  ('136395', 'Marcello', 'Messina', 65, 1350.17, 'impiegato', 'CT01', 'CT01',NULL ),
  ('756439', 'Dustin', 'Adler', 62, 1360.17, 'impiegato', 'BE01', 'BE01',NULL ),
  ('290135', 'Wiston', 'Blue', 41, 1482.12, 'impiegato', 'NY01', 'NY01',NULL ),
  ('889470', 'Giovanni', 'Gurrieri', 16, 1296.78, 'magazziniere', 'CT01', NULL,'IT03' ),
  ('351121', 'Emil', 'Zola', 30, 1300.12, 'magazziniere', 'PA01', NULL,'FR02' ),
  ('938119', 'Homer', 'Simpson', 28, 1352.05, 'magazziniere', 'LA01', NULL,'US01' ),
  ('688903', 'Cloude', 'Monet', 22, 1300.12, 'magazziniere', 'PA01', NULL,'FR01' ),
  ('663508', 'Clint', 'Eastwood', 32, 1352.05, 'magazziniere', 'LA01', NULL,'US01' ),
  ('603259', 'David', 'Delacroix', 60, 1300.12, 'magazziniere', 'PA01', NULL,'FR02' ),
  ('543677', 'Bruce', 'Wayne', 55, 1352.05, 'magazziniere', 'NY01', NULL,'US03' ),
  ('778335', 'Adolf', 'Hahnemann', 18, 1309.23, 'magazziniere', 'BE01', NULL,'DE01' ),
  ('926256', 'Tanja', 'Schroeder', 23, 1309.23, 'magazziniere', 'BE01', NULL,'DE02' ),
  ('159962', 'Jessika', 'Dresker', 60, 1309.23, 'magazziniere', 'BE01', NULL,'DE02' ),
  ('623992', 'GianBaptiste', 'Grenulle', 45, 1300.12, 'magazziniere', 'PA01', NULL,'FR01' ),
  ('215478', 'Alessandro', 'Nesta', 44, 1296.78, 'magazziniere', 'MI01', NULL,'IT01' ),
  ('663857', 'Martina', 'Natch', 43, 1309.23, 'magazziniere', 'BE01', NULL,'DE01' ),
  ('276664', 'Annelien', 'Corvers', 41, 1300.12, 'magazziniere', 'AM01', NULL,'NL01' ),
  ('357715', 'Fabrizio', 'Tarducci', 38, 1296.78, 'magazziniere', 'MI01', NULL,'IT02' ),
  ('737117', 'Pablo', 'Picasso', 37, 1300.12, 'magazziniere', 'BA01', NULL,'ES01' ),
  ('843946', 'Sandra', 'Post', 36, 1352.05, 'magazziniere', 'NY01', NULL,'US02' ),
  ('169836', 'Luis', 'Sal', 33, 1300.12, 'magazziniere', 'BA01', NULL,'ES02' ),
  ('560333', 'Jorre', 'Dik', 20, 1300.12, 'magazziniere', 'AM01', NULL,'NL01' ),
  ('804719', 'Esteban', 'Martinez', 19, 1300.12, 'magazziniere', 'BA01', NULL,'ES02' ),
  ('557777', 'Giovanni', 'Verga', 19, 1296.78, 'magazziniere', 'CT01', NULL,'IT02' ),
  ('843015', 'Francesco', 'Pappa', 19, 1326.50, 'magazziniere', 'CT01', NULL,'UK02' ),
  ('924539', 'Benjamin', 'Burton', 18, 1352.05, 'magazziniere', 'NY01', NULL,'US03' ),
  ('836917', 'Peter', 'Quack', 61, 1323.92, 'magazziniere', 'TO01', NULL,'CA01' ),
  ('224212', 'James', 'Gordon', 60, 1323.92, 'magazziniere', 'TO01', NULL,'CA01' ),
  ('270343', 'Sherlock', 'Holmes', 17, 1326.50, 'magazziniere', 'LO01', NULL,'UK02' ),
  ('672364', 'Bianca', 'Neve', 45, 1296.78, 'magazziniere', 'CT01', NULL,'IT03' ),
  ('232860', 'Timmy', 'Turner', 43, 1326.50, 'magazziniere', 'LO01', NULL,'UK01' ),
  ('712122', 'Vincent', 'Van Gogh', 47, 1300.12, 'magazziniere', 'AM01', NULL,'ES01' ),
  ('688588', 'Freddy', 'kruger', 48, 1352.05, 'magazziniere', 'BO01', NULL,'US04' ),
  ('351081', 'Jeremaia', 'Valesca', 49, 1352.05, 'magazziniere', 'NY01', NULL,'US02' ),
  ('984955', 'Marco', 'Battaglia', 30, 1296.78, 'magazziniere', 'MI01', NULL,'IT01' ),
  ('844202', 'Max', 'Power', 29, 1326.50, 'magazziniere', 'LO01', NULL,'UK01' ),
  ('705736', 'Willie', 'Wonka', 28, 1352.05, 'magazziniere', 'BO01', NULL,'US04' ),
  ('015283', 'Emma', 'Watson', 21, 1874.12, 'autista', 'TO01', NULL,'CA01' ),
  ('012402', 'Diego', 'Mucho', 23, 1774.54, 'autista', 'BA01', NULL,'DE01' ),
  ('974991', 'Juan', 'Mata', 33, 1742.57, 'autista', 'BA01', NULL,'ES02' ),
  ('432673', 'Billie', 'Jonson', 30, 1874.12, 'autista', 'TO01', NULL,'CA01' ),
  ('474129', 'Francis', 'Reno', 27, 1757.88, 'autista', 'PA01', NULL,'FR01' ),
  ('429904', 'Alejandro', 'Gonzalez', 45, 1742.57, 'autista', 'BA01', NULL,'ES01' ),
  ('731745', 'David', 'Fincher', 21, 1759.12, 'autista', 'LO01', NULL,'UK02' ),
  ('491509', 'Richard', 'Wagner', 22, 1774.54, 'autista', 'BE01', NULL,'DE02' ),
  ('645199', 'Luc', 'Besson', 36, 1805.66, 'autista', 'PA01', NULL,'FR02' ),
  ('211249', 'Boston', 'George', 38, 1874.12, 'autista', 'BO01', NULL,'US04' ),
  ('762178', 'Alberto', 'Alberti', 37, 1741.41, 'autista', 'CT01', NULL,'IT03' ),
  ('357369', 'Nicola', 'Albera', 65, 1741.41, 'autista', 'MI01', NULL,'IT01' ),
  ('545521', 'Maurizio', 'Pisciottu', 63, 1759.12, 'autista', 'CT01', NULL,'UK02' ),
  ('388986', 'Frank', 'De Boer', 59, 1774.54, 'autista', 'AM01', NULL,'NL01' ),
  ('791905', 'George', 'Clooney', 57, 1874.12, 'autista', 'LA01', NULL,'US01' ),
  ('950615', 'Woody', 'Allen', 25, 1874.12, 'autista', 'NY01', NULL,'US03' ),
  ('104446', 'Eduardo', 'Mendosa', 63, 1742.57, 'autista', 'BA01', NULL,'ES02' ),
  ('795477', 'Francisco', 'Franco', 68, 1742.57, 'autista', 'BA01', NULL,'ES02' ),
  ('679856', 'Guido', 'Lauto', 48, 1741.41, 'autista', 'MI01', NULL,'IT01' ),
  ('203873', 'Claude', 'Chabroll', 42, 1757.88, 'autista', 'PA01', NULL,'FR02' ),
  ('532739', 'Ugo', 'Foscolo', 27, 1741.41, 'autista', 'MI01', NULL,'IT02' ),
  ('074041', 'Rita', 'Rudner', 26, 1874.12, 'autista', 'NY01', NULL,'US03' ),
  ('094469', 'Lady', 'Diana', 28, 1759.12, 'autista', 'LO01', NULL,'UK01' ),
  ('877127', 'Maria', 'Spinello', 38, 1741.41, 'autista', 'CT01', NULL,'NL01' ),
  ('746049', 'Walfgang', 'Patersen', 33, 1774.54, 'autista', 'BE01', NULL,'DE01' ),
  ('035771', 'Egon', 'Schiele', 47, 1774.54, 'autista', 'BE01', NULL,'DE02' ),
  ('074635', 'Carlo', 'Pane', 44, 1757.88, 'autista', 'MI01', NULL,'FR01' ),
  ('836970', 'Robert', 'De Niro', 51, 1874.12, 'autista', 'NY01', NULL,'US02' ),
  ('206506', 'Rajesh', 'koonthrappali', 20, 1741.41, 'autista', 'MI01', NULL,'IT02' ),
  ('250286', 'Sheldon', 'Cooper', 30, 1874.12, 'autista', 'BO01', NULL,'US04' );

  INSERT INTO Cliente VALUES
  ('Doro00', 'Dorothy' ,'Cain', 15, '2326 Mount Tabor', '10007', 'New York', '5173 7511 1651 6988'),
  ('JoaIs','Joan', 'Israel', 0, '2405 Ashwood Drive', '51525', 'Carson', '4556 2474 6978 9447'),
  ('Chris100','Christopher', 'Sperling', 7, '564 Richison Drive', '59457', 'Lewistown', '5106 4659 8860 5686'),
  ('KimKim25','Kimberly','Brooks', 10, '2001 Hartland Avenue', '54302', 'Green Bay', '5106 4659 8860 5686'),
  ('JShug97','Johnathan','Shugart', 6, '3920 Stark Hollow Road', '80202', 'Denver','5324 7772 5407 8935'),
  ('Smith_D','Dale','Smith', 2, '4848 Benedum Drive', '12401', 'Kingston', '5423 0004 7911 1682'),
  ('LaLaPa','Patricia','Lane', 0, '872 Arbor Court', '82601', 'Casper', '5179 1023 4219 8494'),
  ('WinMitch','Michael','Winland', 8, '4243 Woodland Avenue ', '70001', 'Metairie', '5569 6150 8182 3871'),
  ('McScott','Donald','Scott', 5, '1158 Hillcrest Circle', '55402', 'Minneapolis', '5330 7579 3631 1229'),
  ('MatchMitch','Mitchel','Matchett', 15, '3890 Werninger Street', '77055', 'Houston', '5573 8982 4358 3112'),
  ('ArsRom','Arsenio','Romani', 2, 'via Eugenio Curiel 6', '35138', 'Padova', '4916 5822 2879 0418'),
  ('LuLuPiro','Luana','Pirozzi', 3, 'Via Belviglieri, 103', '00178', 'Roma', '4929 5110 2763 1833'),
  ('Tullio63','Tullio','Calabresi', 0, 'Via Belviglieri 85', '00127', 'Roma', '4485 2418 1115 5478'),
  ('Gaudio99','Gaudenzio','Cremonesi', 14, 'Via Solfatara 147', '14054', 'Castagnole delle Lanze', '4716 2705 8668 0700'),
  ('Melita00','Melisa','Alva', 11, 'Rua da Rapina 89', '37491', 'Robliza de Cojos', '4929 8331 7154 9599'),
  ('GA2407','Gracián','Ávila', 36, 'Ctra. Hornos 54', '26210', 'Cihuri', '5356 7564 5725 5400'),
  ('MolyQ','Quiteria','Molina', 22, 'Rosa de los Vientos, 24', '13350', 'Moral de Calatrava', '4916 2845 9966 7032'),
  ('Dr_Karol','Karolin','Drescher', 0, 'Sömmeringstr 40', '89259', 'Weißenhorn', '5106 4461 5943 0062'),
  ('StefAdl1','Steffen','Adler', 0, 'Meininger Strasse 35', '66550', 'Illingen', '4716 3711 4755 8920'),
  ('Kris88','Kristin','Schiffer', 11, 'Ruschestrasse 86', '39410', 'Staßfurt', '4929 8611 4673 6793'),
  ('WilTia','Tia','Williamson', 12, '24 Whatlington Road', '01108', 'Dresda', '4556 9234 7467 3533'),
  ('ReEth100','Ethan','Reed', 3, '56 St Maurices Road', 'LS28 5BL', 'PUDSEY', '5352 4947 8406 5946'),
  ('Potter02','Megan','Potter', 1, '31 Horsefair Green', 'AB34 9SE', 'OLDHALL', '4539 7226 2430 0340'),
  ('NikiLu','Nikita','Luijks', 16, 'Marktveld 104', '2851 BS ', 'Haastrecht', '5468 2696 9843 5034'),
  ('AK_77','Aimane','Kroese', 25, 'Henri Wijnmalenstraat 124', '3555 VR', 'Utrecht', '5227 4254 1270 8435'),
  ('Lois_St','Lois','Stein', 22, '3083 Brand Road', 'S7K 1W8', 'Saskatoon', '5428 5780 7212 1476'),
  ('MW_Mike','Mike','Walter', 0, '3165 Burdett Avenue', 'V8A 1V6', 'Powell River', '4929 4219 7010 3170'),
  ('Perry_Sv','Perrin','Sevier', 0, '74, rue de la République', '54300', 'LUNÉVILLE', '5247 5039 5048 4621'),
  ('JBJB_123','Joy','Brousseau', 0, '41, rue des Nations Unies', '93200', 'SAINT-DENIS', '5394 2838 9257 1766'),
  ('FL-Anne','Annette','Flamand', 6, '5, rue Pierre Motte', '69110', 'SAINTE-FOY-LÈS-LYON', '4539 3235 4757 0604');

INSERT INTO Merce VALUES
  ('SK001', 'Skateboard', 'Jart', '7.5', 106.99),
  ('SK002', 'Skateboard', 'Jart', '8', 106.99),
  ('SK003', 'Skateboard', 'Jart', '8.25', 106.99),
  ('SK004', 'Skateboard', 'Jart', '8.5', 106.99),
  ('SK005', 'Skateboard', 'Element', '7.5', 99.95),
  ('SK006', 'Skateboard', 'Element', '8', 99.95),
  ('SK007', 'Skateboard', 'Element', '8.5', 99.95),
  ('SK008', 'Skateboard', 'RollingWaves', '7.25', 79.99),
  ('SK009', 'Skateboard', 'RollingWaves', '7.5', 79.99),
  ('SK010', 'Skateboard', 'RollingWaves', '7.75', 79.99),
  ('SK011', 'Skateboard', 'RollingWaves', '8', 79.99),
  ('SK012', 'Skateboard', 'Zero', '7.25', 109.95),
  ('SK013', 'Skateboard', 'Zero', '7.75', 109.95),
  ('SK014', 'Skateboard', 'Zero', '8.25', 109.95),
  ('SN001', 'Snowboard', 'Salomon', '159 cm', 299),
  ('SN002', 'Snowboard', 'Salomon', '167 cm', 299),
  ('SN003', 'Snowboard', 'Burton', '153 cm', 599),
  ('SN004', 'Snowboard', 'Burton', '162 cm', 599),
  ('SN005', 'Snowboard', 'Burton', '165 cm', 599),
  ('SN006', 'Snowboard', 'Nitro', '157 cm', 399.95),
  ('SN007', 'Snowboard', 'Nitro', '167 cm', 399.95),
  ('SN008', 'Snowboard', 'RollingWaves', '155 cm', 259.90),
  ('SN009', 'Snowboard', 'RollingWaves', '159 cm', 259.90),
  ('SN010', 'Snowboard', 'RollingWaves', '162 cm', 259.90),
  ('SN011', 'Snowboard', 'RollingWaves', '167 cm', 259.90),
  ('SU001', 'Tavola da surf', 'Slater', '7.7', 439.90),
  ('SU002', 'Tavola da surf', 'Slater', '9', 439.90),
  ('SU003', 'Tavola da surf', 'Firewire', '9', 899),
  ('SU004', 'Tavola da surf', 'Firewire', '11', 899),
  ('SU005', 'Tavola da surf', 'RollingWaves', '9', 699.90),
  ('TS001', 'T-shirt', 'Element', 'XS', 19.90),
  ('TS002', 'T-shirt', 'Element', 'S', 19.90),
  ('TS003', 'T-shirt', 'Element', 'M', 19.90),
  ('TS004', 'T-shirt', 'Element', 'L', 19.90),
  ('TS005', 'T-shirt', 'Element', 'XL', 19.90),
  ('TS006', 'T-shirt', 'Murder', 'S', 16.99),
  ('TS007', 'T-shirt', 'Murder', 'M', 16.99),
  ('TS008', 'T-shirt', 'Murder', 'L', 16.99),
  ('TS009', 'T-shirt', 'Murder', 'XL', 16.99),
  ('TS010', 'T-shirt', 'RollingWaves', 'S', 13.99),
  ('TS011', 'T-shirt', 'RollingWaves', 'M', 13.99),
  ('TS012', 'T-shirt', 'RollingWaves', 'L', 13.99),
  ('TS013', 'T-shirt', 'RollingWaves', 'XL', 13.99),
  ('TS014', 'T-shirt', 'RollingWaves', 'XXL', 13.99),
  ('PA001', 'Pantaloni', 'RollingWaves', 'S', 30),
  ('PA002', 'Pantaloni', 'RollingWaves', 'M', 30),
  ('PA003', 'Pantaloni', 'RollingWaves', 'L', 30),
  ('PA004', 'Pantaloni', 'Burton', '38', 44.50),
  ('PA005', 'Pantaloni', 'Burton', '40', 44.50),
  ('PA006', 'Pantaloni', 'Burton', '42', 44.50),
  ('PA007', 'Pantaloni', 'Burton', '44', 44.50),
  ('PA008', 'Pantaloni', 'Burton', '46', 44.50),
  ('SH001', 'Scarpe', 'DC shoes', '38', 74.90),
  ('SH002', 'Scarpe', 'DC shoes', '39', 74.90),
  ('SH003', 'Scarpe', 'DC shoes', '40', 74.90),
  ('SH004', 'Scarpe', 'DC shoes', '41', 74.90),
  ('SH005', 'Scarpe', 'DC shoes', '41.5', 74.90),
  ('SH006', 'Scarpe', 'DC shoes', '42', 74.90),
  ('SH007', 'Scarpe', 'DC shoes', '43', 74.90),
  ('SH008', 'Scarpe', 'DC shoes', '44', 74.90),
  ('SH009', 'Scarpe', 'Globe', '40', 84.99),
  ('SH010', 'Scarpe', 'Globe', '41', 84.99),
  ('SH011', 'Scarpe', 'Globe', '42', 84.99),
  ('SH012', 'Scarpe', 'Globe', '43', 84.99),
  ('SH013', 'Scarpe', 'Globe', '44', 84.99),
  ('SH014', 'Scarpe', 'Globe', '45', 84.99),
  ('SH015', 'Scarpe', 'Globe', '46', 84.99),
  ('SH016', 'Scarpe', 'Etnies', '38', 80),
  ('SH017', 'Scarpe', 'Etnies', '39', 80),
  ('SH018', 'Scarpe', 'Etnies', '40', 80),
  ('SH019', 'Scarpe', 'Etnies', '40.5', 80),
  ('SH020', 'Scarpe', 'Etnies', '41', 80),
  ('SH021', 'Scarpe', 'Etnies', '41.5', 80),
  ('SH022', 'Scarpe', 'Etnies', '42', 80),
  ('SH023', 'Scarpe', 'Etnies', '43', 80),
  ('SH024', 'Scarpe', 'Etnies', '44', 80),
  ('SH025', 'Scarpe', 'Etnies', '45', 80),
  ('SH026', 'Scarpe', 'Etnies', '46', 80);

INSERT INTO Fornitore VALUES
  ('02337350421', 'Element', 'Element@shop.com', '408-926-8223'),
  ('10365441004', 'Globe', 'Globe@shop.com', '219-608-4463'),
  ('01663820502', 'Jart', 'Jart@shop.com', '918-631-3277'),
  ('03721820409', 'Etnies', 'Etnies@shop.com', '732-515-4348'),
  ('06170860966', 'Zero', 'Zero@shop.com', '920-619-7582'),
  ('00455570713', 'Burton', 'Burton@shop.com', '208-837-1636'),
  ('02369700188', 'Fireware', 'Fireware@shop.com', '504-722-6700'),
  ('02156380426', 'Slater', 'Slater@shop.com', '870-867-0395'),
  ('94213740486', 'Nitro', 'Nitro@shop.com', '678-409-3685'),
  ('02607430218', 'Salomon', 'Salomon@shop.com', '404-261-7931'),
  ('02225920160', 'Murder', 'Murder@shop.com', '510-837-8852'),
  ('96042280782', 'DC shoes', 'DC-shoes@shop.com', '734-378-4198');

INSERT INTO Ordine VALUES
  ('#JV26xM8VyH', 186.99, 'US03', 'KimKim25', 'NY01', 'tcBDuSP5H6Ew', false, '2020-12-12'),
  ('#7R5sSOQCt3', 599.00, 'IT01', 'ArsRom', 'MI01', 'FViyKyQn7SqD', false, '2020-12-11'),
  ('#IELoWMf7n7', 164.99, 'FR01', 'Perry_Sv', 'PA01', 'SSTXt3FXSn4k', false, '2018-05-07'),
  ('#arhQxHKIkZ', 39.80, 'DE01', 'Dr_Karol', 'BE01', 'DLcKVKjkygja', false, '2019-07-30'),
  ('#DMuG96htjs', 61.49, 'NL01', 'AK_77', 'AM01', 'QHn3wBzuegET', false, '2020-04-21'),
  ('#YytP23mlDy', 599.00, 'DE02', 'Kris88', 'BE01', '2kGsCTY9AC3Y', false, '2019-11-30'),
  ('#81fEaUAJBz', 799.9, 'US01', 'JShug97', 'LA01', 'yQAWtVRIUTDM', false, '2020-11-26'),
  ('#tavgLyvwL6', 483.89, 'IT03', 'Gaudio99', 'CT01', 'wV6ZDI1dKx4n', false, '2020-06-29'),
  ('#6ijFhvMN0x', 50.88, 'FR02', 'FL-Anne', 'PA01', '2seN5vTh7GKh', false, '2020-09-29'),
  ('#YzvmHYvg0O', 564.94, 'NL01', 'NikiLu', 'AM01', '0CgOSOY9tAOd', false, '2018-06-26'),
  ('#YEtxBh3Tpg', 80.00, 'US02', 'Doro00', 'NY01', 'jjJHp0Nh5wGD', true, '2019-01-15'),
  ('#WjDRePB4ON', 80.00, 'US02', 'Doro00', 'NY01', 'pFfTd2pTMTeY', false, '2018-12-23'),
  ('#S1g8pfbhHA', 91.89, 'IT02', 'Tullio63', 'MI01', 'NOnBka8OOMzy', false, '2018-11-15'),
  ('#lsMewzCuXS', 216.94, 'US02', 'Doro00', 'NY01', 'FpEKfrqXh1gU', false, '2020-08-12'),
  ('#rzYKBaJsgJ', 99.95, 'US01', 'JoaIs', 'LA01', 'OX4I4oBr7i2R', false, '2020-12-28'),
  ('#FI0TZOHC1X', 862.88, 'CA01', 'Lois_St', 'TO01', '0myhNoeBf3Qv', false, '2020-03-15'),
  ('#otI0Gfz1OS', 113.94, 'US01', 'JShug97', 'LA01', 'cqPKTHKpn1oO', true, '2021-01-05'),
  ('#smrX3V54yl', 329.85, 'US01', 'JShug97', 'LA01', 'sp7MpGucAQh6', false, '2021-01-05'),
  ('#ZczSeCzBh0', 1598.90, 'IT02', 'LuLuPiro', 'MI01', '4NfanF6DZLVB', false, '2020-03-11'),
  ('#dzodAGzO0E', 312.88, 'ES02', 'Melita00', 'BA01', '1uoCZayPjI9e', false, '2020-05-12'),
  ('#NIIegkOVHB', 299.00, 'US04', 'MatchMitch', 'BO01', 'K9WrGDym9YOr', false, '2019-05-06'),
  ('#5uYZ9YNTQ2', 320.97, 'DE01', 'WilTia', 'BE01', 'FAwlSjOFNiYR', false, '2019-12-15'),
  ('#pj8SiZcyPc', 1598.90, 'ES02', 'GA2407', 'BA01', '06sjwT2WHMUu', false, '2020-05-01'),
  ('#TdzdyXXA5n', 95.38, 'NL01', 'NikiLu', 'AM01', 'JQroGRSpneVq', true, '2029-12-11'),
  ('#LBagNXPsXC', 413.94, 'NL01', 'NikiLu', 'AM01', 'aY6T8AVqOT6N', false, '2019-12-11'),
  ('#Xf2zlvIfJe', 74.50, 'NL01', 'ReEth100', 'AM01', 'BhjEEsNSuu8Q', false, '2018-12-16'),
  ('#cQYjWdLZFW', 534.95, 'US03', 'McScott', 'NY01', 'SwfOIkQp65T7', false, '2019-09-09'),
  ('#L69z6NNA5W', 299.00, 'US03', 'Smith_D', 'NY01', 'hBfvSoAlPwcI', false, '2020-02-20'),
  ('#4ja1SFFdcB', 39.80, 'US01', 'WinMitch', 'LA01', '0lSb6foYxKja', false, '2020-01-19'),
  ('#Y7qLTtc6st', 191.39, 'FR02', 'FL-Anne', 'PA01', '3Y4mewIT1J2M', false, '2019-05-31'),
  ('#8y4m8aeh8S', 159.89, 'IT03', 'Gaudio99', 'CT01', 'cirgrviMkPK3', false, '2020-12-31');

INSERT INTO Composizione_Ordine VALUES --prodotti quantità singola
  ('#JV26xM8VyH', 'SK004'),
  ('#JV26xM8VyH', 'SH018'),
  ('#7R5sSOQCt3', 'SN007'),
  ('#IELoWMf7n7', 'SH016'),
  ('#IELoWMf7n7', 'SH012'),
  ('#DMuG96htjs', 'TS007'),
  ('#DMuG96htjs', 'PA006'),
  ('#YytP23mlDy', 'SN004'),
  ('#tavgLyvwL6', 'SU001'),
  ('#tavgLyvwL6', 'PA003'),
  ('#tavgLyvwL6', 'TS011'),
  ('#6ijFhvMN0x', 'TS002'),
  ('#6ijFhvMN0x', 'TS008'),
  ('#6ijFhvMN0x', 'TS014'),
  ('#YzvmHYvg0O', 'SN005'),
  ('#YzvmHYvg0O', 'SH012'),
  ('#YzvmHYvg0O', 'SH017'),
  ('#YEtxBh3Tpg', 'SH022'),
  ('#WjDRePB4ON', 'SH023'),
  ('#S1g8pfbhHA', 'SH003'),
  ('#S1g8pfbhHA', 'TS007'),
  ('#lsMewzCuXS', 'SK014'),
  ('#lsMewzCuXS', 'SK003'),
  ('#rzYKBaJsgJ', 'SK005'),
  ('#FI0TZOHC1X', 'SK001'),
  ('#FI0TZOHC1X', 'SN002'),
  ('#FI0TZOHC1X', 'SU003'),
  ('#FI0TZOHC1X', 'TS007'),
  ('#otI0Gfz1OS', 'TS013'),
  ('#otI0Gfz1OS', 'SK006'),
  ('#ZczSeCzBh0', 'SU004'),
  ('#ZczSeCzBh0', 'SU005'),
  ('#dzodAGzO0E', 'SK010'),
  ('#dzodAGzO0E', 'SH021'),
  ('#dzodAGzO0E', 'TS008'),
  ('#dzodAGzO0E', 'TS003'),
  ('#NIIegkOVHB', 'SN001'),
  ('#pj8SiZcyPc', 'SU004'),
  ('#pj8SiZcyPc', 'SU005'),
  ('#TdzdyXXA5n', 'TS001'),
  ('#TdzdyXXA5n', 'TS006'),
  ('#TdzdyXXA5n', 'TS010'),
  ('#TdzdyXXA5n', 'PA005'),
  ('#LBagNXPsXC', 'SN006'),
  ('#LBagNXPsXC', 'TS011'),
  ('#Xf2zlvIfJe', 'PA006'),
  ('#Xf2zlvIfJe', 'PA002'),
  ('#L69z6NNA5W', 'SN001'),
  ('#Y7qLTtc6st', 'TS003'),
  ('#Y7qLTtc6st', 'TS007'),
  ('#Y7qLTtc6st', 'PA002'),
  ('#Y7qLTtc6st', 'PA006'),
  ('#Y7qLTtc6st', 'SH021'),
  ('#8y4m8aeh8S', 'SH005'),
  ('#8y4m8aeh8S', 'SH011');

INSERT INTO Composizione_Ordine VALUES --prodotti quantità multipla
  ('#arhQxHKIkZ', 'TS002', 2),
  ('#81fEaUAJBz', 'SN007', 2),
  ('#smrX3V54yl', 'SK013', 3),
  ('#dzodAGzO0E', 'PA002', 2),
  ('#5uYZ9YNTQ2', 'SK002', 3),
  ('#cQYjWdLZFW', 'SK004', 5),
  ('#4ja1SFFdcB', 'TS001', 2);

INSERT INTO Operazioni_Magazzino VALUES
  ('2020-12-13 06:45:27', 'US03', 'carico'),
  ('2020-12-04 07:22:15', 'US02', 'carico'),
  ('2020-12-12 08:33:27', 'US03', 'carico'),
  ('2020-12-12 17:30:00', 'US03', 'scarico'),
  ('2020-12-12 09:53:17', 'IT01', 'carico'),
  ('2020-12-01 07:14:59', 'IT01', 'scarico'),
  ('2018-05-08 18:00:03', 'FR01', 'carico'),
  ('2018-04-29 10:11:12', 'FR01', 'scarico'),
  ('2018-04-29 17:28:44', 'FR01', 'carico'),
  ('2019-08-01 15:58:02', 'DE01', 'carico'),
  ('2019-05-25 16:45:24', 'DE02', 'scarico'),
  ('2020-04-21 06:13:22', 'NL01', 'scarico'),
  ('2020-04-22 06:13:22', 'NL01', 'carico'),
  ('2019-11-30 05:47:06', 'CA01', 'scarico'),
  ('2020-03-12 19:36:32', 'IT02', 'carico'),
  ('2020-03-01 19:36:32', 'ES02', 'scarico'),
  ('2020-03-01 16:00:15', 'ES01', 'scarico'),
  ('2018-12-23 15:12:09', 'ES02', 'carico'),
  ('2019-04-21 05:48:27', 'ES01', 'scarico'),
  ('2020-04-21 12:12:12', 'ES01', 'carico'),
  ('2019-03-01 11:27:27', 'UK02', 'scarico');

INSERT INTO Esecuzione_Operazioni_Magazzino VALUES
  ('US03', '543677', '2020-12-13 06:45:27'),
  ('US02', '843946', '2020-12-04 07:22:15'),
  ('US03', '924539', '2020-12-12 08:33:27'),
  ('US03', '543677', '2020-12-12 17:30:00'),
  ('US03', '924539', '2020-12-12 17:30:00'),
  ('IT01', '984955', '2020-12-12 09:53:17'),
  ('IT01', '215478', '2020-12-01 07:14:59'),
  ('IT01', '984955', '2020-12-01 07:14:59'),
  ('FR01', '688903', '2018-05-08 18:00:03'),
  ('FR01', '623992', '2018-04-29 18:00:03'),
  ('FR01', '623992', '2018-04-29 10:11:12'),
  ('FR01', '688903', '2018-04-29 17:28:44'),
  ('DE01', '663857', '2019-08-01 15:58:02'),
  ('DE02', '926256', '2019-05-25 16:45:24'),
  ('DE02', '159962', '2019-05-25 16:45:24'),
  ('NL01', '276664', '2020-04-21 06:13:22'),
  ('NL01', '560333', '2020-04-21 06:13:22'),
  ('NL01', '560333', '2020-04-22 06:13:22'),
  ('IT02', '357715', '2020-03-12 19:36:32'),
  ('ES02', '169836', '2020-03-01 19:36:32'),
  ('ES02', '804719', '2020-03-01 19:36:32'),
  ('ES01', '737117', '2020-03-01 16:00:15'),
  ('ES01', '712122', '2020-03-01 16:00:15'),
  ('ES02', '169836', '2018-12-23 15:12:09'),
  ('ES02', '804719', '2018-12-23 15:12:09'),
  ('ES01', '737117', '2019-04-21 05:48:27'),
  ('ES01', '712122', '2019-04-21 05:48:27'),
  ('ES01', '712122', '2020-04-21 12:12:12'),
  ('UK02', '843015', '2019-03-01 11:27:27'),
  ('UK02', '270343', '2019-03-01 11:27:27');

INSERT INTO Carrello VALUES
  ('MatchMitch','SK003', 1),
  ('MatchMitch','TS008', 1),
  ('Kris88','SU003', 1),
  ('LaLaPa','SK010', 2),
  ('ArsRom','SN011', 1),
  ('ArsRom','SK003', 1),
  ('ArsRom','SK009', 1),
  ('MW_Mike','SH002', 2),
  ('MW_Mike','PA004', 1),
  ('NikiLu','TS010', 3);

INSERT INTO Consegna VALUES
  ('950615', 'KimKim25', '2020-12-20'),
  ('679856', 'ArsRom', '2020-12-17'),
  ('791905', 'JShug97', '2021-01-11'),
  ('877127', 'AK_77', '2020-04-25'),
  ('795477', 'GA2407', '2020-05-07'),
  ('645199', 'FL-Anne', '2020-10-03'),
  ('206506', 'LuLuPiro', '2020-03-21'),
  ('074635', 'Perry_Sv', '2018-05-11'),
  ('791905', 'JoaIs', '2020-12-28'),
  ('015283', 'Lois_St', '2020-03-20'),
  ('250286', 'MatchMitch', '2019-05-12'),
  ('791905', 'WinMitch', '2020-01-22'),
  ('645199', 'FL-Anne', '2019-06-04'),
  ('074041', 'McScott', '2019-09-19'),
  ('791905', 'JShug97', '2020-11-30');

INSERT INTO Deposito VALUES
  ('SK001', 'US01', 2),
  ('SK006', 'US01', 5),
  ('SK003', 'IT03', 0),
  ('SK014', 'US01', 26),
  ('SN001', 'US02', 13),
  ('SN002', 'CA01', 10),
  ('SN005', 'NL01', 11),
  ('SN007', 'IT03', 15),
  ('SU005', 'IT03', 26),
  ('SU002', 'US01', 16),
  ('SU004', 'NL01', 13),
  ('TS012', 'US02', 33),
  ('TS008', 'US01', 17),
  ('TS003', 'IT03', 15),
  ('PA002', 'FR01', 26),
  ('PA005', 'FR01', 15),
  ('SH026', 'IT03', 15),
  ('SH017', 'US02', 7),
  ('SH003', 'FR01', 8),
  ('SK004', 'IT03', 26),
  ('SN001', 'NL01', 13),
  ('SK002', 'ES01', 3),
  ('SK010', 'IT02', 15),
  ('SK002', 'IT02', 6),
  ('SN002', 'UK02', 9),
  ('SN003', 'ES01', 11),
  ('SN004', 'NL01', 0),
  ('SU004', 'UK02', 8),
  ('SU005', 'NL01', 6),
  ('SU001', 'DE01', 7),
  ('SK003', 'NL01', 10),
  ('SK006', 'ES01', 2),
  ('SK001', 'DE01', 12),
  ('SK004', 'DE01', 21),
  ('SU003', 'CA01', 5),
  ('SN001', 'CA01', 0),
  ('SH026', 'IT02', 20),
  ('SH022', 'US02', 0);

INSERT INTO Merce_prenotata VALUES
  ('LA01', '01663820502', 'SK002', 20, '2020-11-30'),
  ('CT01', '02337350421', 'SK006', 32, '2018-12-15'),
  ('LO01', '00455570713', 'SN007',  15, '2019-02-06'),
  ('LO01', '00455570713', 'SN006',  5, '2019-02-06'),
  ('BA01', '02337350421', 'SK006',  45, '2019-06-06'),
  ('MI01', '96042280782', 'SH003', 15, '2020-05-15'),
  ('LO01', '10365441004', 'SH009', 20, '2020-05-15'),
  ('NY01', '00455570713', 'SN004', 10, '2020-01-15'),
  ('NY01', '00455570713', 'SN006', 15, '2018-12-10'),
  ('NY01', '00455570713', 'PA005', 18, '2020-06-15'),
  ('TO01', '06170860966', 'SK013', 35, '2020-07-07'),
  ('TO01', '03721820409', 'SH019', 20, '2020-07-07'),
  ('TO01', '02337350421', 'TS002', 30, '2020-07-07'),
  ('AM01', '02156380426', 'SU001', 15, '2019-05-30'),
  ('TO01', '02156380426', 'SU002', 5, '2020-07-15');

INSERT INTO Rifornimento_Merce VALUES
  ('US01', '01663820502', 'SK002', 20, '2020-12-07'),
  ('IT03', '02337350421', 'SK006', 32, '2018-12-22'),
  ('UK01', '00455570713', 'SN007', 15, '2019-02-13'),
  ('UK01', '00455570713', 'SN006', 5, '2019-02-13'),
  ('ES02', '02337350421', 'SK006', 45, '2019-06-13'),
  ('IT01', '96042280782', 'SH003', 15, '2020-05-22'),
  ('UK02', '10365441004', 'SH009', 20, '2020-05-22'),
  ('US02', '00455570713', 'SN004', 10, '2020-01-22'),
  ('US02', '00455570713', 'SN006', 15, '2018-12-17'),
  ('US03', '00455570713', 'PA005', 18, '2020-06-22'),
  ('CA01', '06170860966', 'SK013', 35, '2020-07-14'),
  ('CA01', '03721820409', 'SH019', 20, '2020-07-14'),
  ('CA01', '02337350421', 'TS002', 30, '2020-07-14'),
  ('NL01', '02156380426', 'SU001', 15, '2019-06-07'),
  ('CA01', '02156380426', 'SU002', 5, '2020-07-22');

INSERT INTO Stipendio VALUES
  ('w8ApyJhywiDi', 3057.86, '2020-01-15', '003568', 'LO01'),
  ('tcbjKYeLmima', 3057.86, '2020-02-15', '003568', 'LO01'),
  ('Vp9nateEdMVj', 3057.86, '2020-03-15', '003568', 'LO01'),
  ('kPslcIocyKcw', 1482.12, '2020-01-15', '710799', 'NY01'),
  ('hvvCocPY4OEo', 1482.12, '2020-02-15', '710799', 'NY01'),
  ('aqen4EZx2i5U', 1482.12, '2020-03-15', '710799', 'NY01'),
  ('eDi4entI4f4p', 1350.17, '2020-01-15', '136395', 'CT01'),
  ('Y9ozGGUDZYJb', 1350.17, '2020-02-15', '136395', 'CT01'),
  ('wwDsOxEE8voO', 1350.17, '2020-03-15', '136395', 'CT01'),
  ('UzE5Kg8u2SMc', 1482.12, '2020-01-15', '290135', 'NY01'),
  ('PsgrLphxW1z3', 1482.12, '2020-02-15', '290135', 'NY01'),
  ('w53JY9bAAOiK', 1482.12, '2020-03-15', '290135', 'NY01'),
  ('Vxwikynilyra', 1352.05, '2020-01-15', '938119', 'LA01'),
  ('35ONWSUR5n9M', 1352.05, '2020-02-15', '938119', 'LA01'),
  ('0rRol3pCaDPM', 1352.05, '2020-03-15', '938119', 'LA01'),
  ('ETHSeK2SiXfZ', 1309.23, '2020-01-15', '159962', 'BE01'),
  ('VvmnJ3AYSdbt', 1309.23, '2020-02-15', '159962', 'BE01'),
  ('HOBV3q0Qccq9', 1309.23, '2020-03-15', '159962', 'BE01'),
  ('JnHaCvj90mT5', 1296.78, '2020-01-15', '357715', 'MI01'),
  ('yY2AdKYggvNi', 1296.78, '2020-02-15', '357715', 'MI01'),
  ('SJgTb6Z7QqPG', 1296.78, '2020-03-15', '357715', 'MI01'),
  ('cwiDcx7RhgDy', 1300.12, '2020-01-15', '169836', 'BA01'),
  ('C9MXYFNb4cm5', 1300.12, '2020-02-15', '169836', 'BA01'),
  ('OxNZCQL2Q9IB', 1300.12, '2020-03-15', '169836', 'BA01'),
  ('Zu4kOPiKVTzh', 1741.41, '2020-01-15', '679856', 'MI01'),
  ('rEb2oBTgpt1k', 1741.41, '2020-02-15', '679856', 'MI01'),
  ('8NjtJWK5CWnT', 1741.41, '2020-03-15', '679856', 'MI01'),
  ('Yyc1tU2FDS31', 1741.41, '2020-01-15', '877127', 'AM01'),
  ('ZUtKoNOCJoQa', 1741.41, '2020-02-15', '877127', 'AM01'),
  ('lattEqAedBfK', 1741.41, '2020-03-15', '877127', 'AM01'),
  ('da8KyQSqfSHd', 1774.54, '2020-01-15', '746049', 'BE01'),
  ('KGPJ67xd3An8', 1774.54, '2020-02-15', '746049', 'BE01'),
  ('TBfVsWuL8HXK', 1774.54, '2020-03-15', '746049', 'BE01'),
  ('UVHN1hpHpgXs', 1874.12, '2020-01-15', '950615', 'NY01'),
  ('vOX28Xpb3wrt', 1874.12, '2020-02-15', '950615', 'NY01'),
  ('BtBQlgOfblpc', 1874.12, '2020-03-15', '950615', 'NY01'),
  ('0erpiWkuLSfY', 1759.12, '2020-01-15', '545521', 'CT01'),
  ('lgifeBhsXTk6', 1759.12, '2020-02-15', '545521', 'CT01'),
  ('2B9Pvssn5iq0', 1759.12, '2020-03-15', '545521', 'CT01'),
  ('Q73otEfFZMin', 1352.05, '2020-01-15', '705736', 'BO01'),
  ('bAEDwb7iqdMj', 1352.05, '2020-02-15', '705736', 'BO01'),
  ('jX3Yd8S2s9mc', 1352.05, '2020-03-15', '705736', 'BO01'),
  ('O3sEKY7t4ofp', 1874.12, '2020-01-15', '250286', 'BO01'),
  ('ArShac8PQfq9', 1874.12, '2020-02-15', '250286', 'BO01'),
  ('7i1G0KCabtLq', 1874.12, '2020-03-15', '250286', 'BO01'),
  ('E6Bb6EgCoL5I', 1741.41, '2020-01-15', '206506', 'MI01'),
  ('7o5c3LXfjRAM', 1741.41, '2020-02-15', '206506', 'MI01'),
  ('IxFTlLJZJrQl', 1741.41, '2020-03-15', '206506', 'MI01'),
  ('7RMdXubAdsb4', 1757.88, '2020-01-15', '074635', 'MI01'),
  ('MIO0XmwpHzvW', 1757.88, '2020-02-15', '074635', 'MI01'),
  ('TLc72w5raXWy', 1757.88, '2020-03-15', '074635', 'MI01');

INSERT INTO Fattura VALUES
  ('W1KSXgfJwsnP', 1320.00,'2020-11-30', '01663820502', 'LA01'),
  ('wXzfD6xCiK9v', 1918.40,'2018-12-15', '02337350421','CT01'),
  ('ay2ZewVmPRVg', 7980.00,'2019-02-06', '00455570713','LO01'),
  ('RaFicKKME2cS', 2697.75,'2019-06-06', '02337350421','BA01'),
  ('a6KHC70ESiSx', 673.50,'2020-05-15', '96042280782','MI01'),
  ('pTTBltGgwcno', 1099.80,'2020-05-15', '10365441004','LO01'),
  ('OtqCLIuY62vA', 3990.00,'2020-01-15', '00455570713','NY01'),
  ('5zVnV8W6yzEW', 5985.00,'2018-12-10', '00455570713','NY01'),
  ('g3u63yRCUYPh', 441.00,'2020-06-15', '00455570713','NY01'),
  ('WBucxX0RQ26X', 2446.50,'2020-07-07', '06170860966','NY01'),
  ('gJfGdcNXcRcj', 1000,'2020-07-07', '03721820409','NY01'),
  ('sL4g226Dxzry', 297.00,'2020-07-07', '02337350421','NY01'),
  ('9Q5D0hKvbR4J', 4348.50,'2019-05-30', '02156380426','AM01'),
  ('AglL16FbFdWZ', 1449.5,'2020-07-15', '02156380426','NY01');

INSERT INTO Incasso VALUES
  ('4weuZa27JWt8', 186.99, '2020-12-12', 'KimKim25', 'NY01'),
  ('pkb7laGbgVRs', 599.00, '2020-12-11', 'ArsRom', 'MI01'),
  ('05kVHDXrOKXt', 164.99,'2018-05-07', 'Perry_Sv', 'PA01'),
  ('NAbnQWZPLyEi', 39.80,'2019-07-30', 'Dr_Karol', 'BE01'),
  ('4qPGi01XvzBO', 61.49,'2020-04-21', 'AK_77', 'AM01'),
  ('2JnAFo5Zrive', 599.00,'2019-11-30', 'Kris88', 'BE01'),
  ('o59LsSF231a8', 799.90,'2020-11-26', 'JShug97', 'LA01'),
  ('118rvESYNDdC', 483.89,'2020-06-29', 'Gaudio99', 'CT01'),
  ('2jeRBUl4yEVB', 50.88,'2020-09-29', 'FL-Anne', 'PA01'),
  ('l8fGvAWGr6WZ', 564.94,'2018-06-26', 'NikiLu', 'AM01'),
  ('vO65r4lzYyC1', 80.00,'2018-12-23', 'Doro00', 'NY01'),
  ('zHCkBHlcEepl', 91.89,'2018-11-15', 'Tullio63', 'MI01'),
  ('lxaZjPVMeRx9', 216.94,'2020-08-12', 'Doro00', 'NY01'),
  ('fzJyTXwqgnto', 99.95,'2020-12-28', 'JoaIs', 'LA01'),
  ('KpM9nclqCPVK', 862.88,'2020-03-15', 'Lois_St', 'TO01'),
  ('V0aLaeVhp2A1', 329.85,'2021-01-05', 'JShug97', 'LA01'),
  ('qtfNlufyaMoD', 1598.90,'2020-03-11', 'LuLuPiro', 'MI01'),
  ('rKVCACCRMsYG', 312.88,'2020-05-12', 'Melita00', 'BA01'),
  ('NkB7Ne6Kt3Pw', 299.00,'2019-05-06', 'MatchMitch', 'BO01'),
  ('0RkfwsYaeG3z', 320.97,'2019-12-15', 'WilTia', 'BE01'),
  ('Fn9lpxBju650', 1598.90,'2020-05-01', 'GA2407', 'BA01'),
  ('XXBzfIQAqDDg', 413.94,'2019-12-11', 'NikiLu', 'AM01'),
  ('i26ah7xBDz6p', 74.50,'2018-12-16', 'ReEth100', 'AM01'),
  ('p9zxMMH0H157', 534.95,'2019-09-09', 'McScott', 'NY01'),
  ('W714YXq6elPr', 299.00,'2020-02-20', 'Smith_D', 'NY01'),
  ('Tbct30vqAfaY', 39.80,'2020-01-19', 'WinMitch', 'LA01'),
  ('Ogyn8993QFjy', 191.39,'2019-05-31', 'FL-Anne', 'PA01'),
  ('GEWsuTpO5uFL', 159.89,'2020-12-31', 'Gaudio99', 'CT01');
--FINE POPOLAMENTO


--CREAZIONE INDICI

/*
l'operazione di controllo merci in deposito è essenziale sia per la prenotazione di merci che per la
disponibilità all'acquisto. Motivo per cui l'operazione viene eseguita svariate volte ogni giorno.
Per questo si è quindi scelto di creare un indice per la quantità di merce in deposito.
*/
drop index if exists quantita_in_magazzino;
create index quantita_in_magazzino on deposito(quantita);

  /*
  La data in cui è stato effettuato un ordine è un dato molto importante sia per il cliente che per le sedi
  in quanto viene data al cliente la possibilità di filtrare lo storico ordini in base alla data. Lo stesso
  vale per le sedi e per questo motivo si è scelto di creare un indice sulla data di prenotazione dell'ordine.

  */
  drop index if exists data;
  create index data on ordine(data);

--QUERY

/*
  QUERY 1:
  Scontare del 20% tutti i prodotti invenduti durante l'anno corrente (2020),
  mostrare il risultato ordinando il prezzo in ordine decrescente.
*/
update merce
set prezzo = prezzo-(prezzo*20)/100
where ID in (select ID
			from merce
			 EXCEPT
			 select prodotto
			 from composizione_ordine join ordine on ordine.numeroOrdine = composizione_ordine.ordine
			 where data > '2019-12-31'
			);
select *
from merce
order by prezzo desc;

/*
  QUERY 2:
   Mostrare a schermo il miglior autista (quello che ha effettuato più consegne) dell'azienza indicandone
   nome, cognome, matricola e la sede nella quale egli è impiegato.
*/
select dipendente.matricola, dipendente.nome, dipendente.cognome, sede.id as Sede
from(
		select max(dipendente) as matricola
		from(
				select dipendente, count(Cliente)
				from consegna
				group by dipendente) as ID) as migliorAutista, dipendente, magazzino, sede
		where migliorAutista.matricola=Dipendente.matricola and
				dipendente.magazzinoAfferito = magazzino.id and
				magazzino.gestore = sede.id;

/*
  QUERY 3:
  Si desidera conoscere quali fornitori devono essere contattati da ciascuna sede
  per la prenotazione delle merci.
  La merce da prenotare è quella che ha una quantità in deposito <= 10
  Del fornitore si desidera conoscere:
  il nome, la mail e la partita IVA in modo da poterlo contattare ed effettuare il pagamento
  ordinare il tutto in modo che le stesse sedi compaiano in righe consecutive
*/
select sede.id as Sede, merce.id, merce.tipo, deposito.quantita, fornitore.nome, fornitore.email, fornitore.partitaIVA
from merce, deposito, fornitore, magazzino, sede
where prodotto = merce.id
      and fornitore.nome = merce.marca
      and deposito.magazzino = magazzino.id
      and deposito.quantita <= 10
      and magazzino.gestore = sede.id
order by sede.id;

/*
  QUERY 4:
  calcolare il bilancio annuo (2020) di ciascuna sede
*/

--per semplicità creiamo due viste riguardanti rispettivamente le entrate annue e le uscite annue
drop view if exists entrate_2020;
create view entrate_2020(sede, importo) as
select gestito_da_sede as sede, sum(totale) as importo
from ordine
where data > '2019-12-31' and data < '2021-01-01'
group by gestito_da_sede;

drop view if exists uscite_2020;
create view uscite_2020(sede, importo) as
select sede, sum(importo) as importo
from(
		select trasmittente as sede, sum(importo) as importo
		from stipendio
		where data > '2019-12-31'and data < '2021-01-01'
		group by sede
		UNION
		select trasmittente as sede, sum(importo) as importo
		from fattura
		where data > '2019-12-31'and data < '2021-01-01'
		group by sede
	) as uscite
group by sede;

select *
from Entrate_2020
where sede not in (select sede from Uscite_2020 )
UNION
select *
from Uscite_2020
where sede not in (select sede from Entrate_2020)
UNION
select Entrate_2020.sede, Entrate_2020.importo - Uscite_2020.importo
from Entrate_2020,Uscite_2020
where Entrate_2020.sede = Uscite_2020.sede;

/*Realisticamente basterebbe solo la query seguente:
    select Entrate_2020.sede, Entrate_2020.importo - Uscite_2020.importo
    from Entrate_2020,Uscite_2020
    where Entrate_2020.sede = Uscite_2020.sede
ma essendo il db non completamente riempito, per completezza, al fine di mostrare i giusti risultati ,
si contano anche sedi che non hanno percepito entrate o emesso uscite.
*/

/*
  QUERY 5
  mostrate per ogni amministratore la sede amministrata e l'elenco dei dipendenti che lavorano in ciascuna sede,
  il tutto ordinato per sede in ordine alfabetico
  In particolare della sede verranno mostrati l'id e la città in cui essa si trova;
                del direttore verrà mostrata la matricola, il nome e il cognome;
                dei dipendenti verranno mostrati la matricola, il nome, il cognome e la mansione svolta.
*/
select sede.id as sede, sede.citta as stabilimento,
       direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore,
       R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego
from sede, dipendente, dipendente as R1
where sede.direttore = dipendente.matricola
  and R1.sedeafferita = sede.id
UNION
select sede.id as sede, sede.citta as stabilimento,
       direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore,
       R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego
from sede, dipendente, dipendente as R1, magazzino
where sede.direttore = dipendente.matricola
    and R1.magazzinoafferito = magazzino.id
    and magazzino.gestore = sede.id
EXCEPT
select sede.id as sede, sede.citta as stabilimento,
       direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore,
       R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego
from sede, dipendente, dipendente as R1
where direttore = R1.matricola
order by stabilimento;

/*
  QUERY 6
  Mostrare la top 5 degli articoli più venduti durante l'anno corrente (2020)
  In particolare si mostrino:
        L'ID, il tipo, e la marca del prodotto e quanti pezzi ne sono stati venduti
*/
select merce.id, merce.tipo, merce.marca, COUNT(*) AS quantita
from merce, composizione_ordine, ordine
where merce.id = composizione_ordine.prodotto
		AND composizione_ordine.ordine = ordine.numeroOrdine
		AND ordine.data > '2019-12-31' AND ordine.data < '2021-01-01'
		AND ordine.annullato = 'false'
group BY (merce.id, merce.tipo, merce.marca)
order BY quantita DESC
LIMIT 5;
