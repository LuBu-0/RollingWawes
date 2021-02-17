#include <iostream>
#include "libpq-fe.h"
#include <iomanip>

using std::cout;
using std::endl;
using std::cerr;
using std::setw;

#define PG_HOST "127.0.0.1"
#define PG_USER "postgres" // il vostro nome utente
#define PG_DB "RollingWaves" // il nome del database
#define PG_PASS "Password" // la vostra password
#define PG_PORT 5432

int main() {
    char conninfo[250];
    sprintf (conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d ", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

    PGconn* conn = PQconnectdb(conninfo);
    
    if(PQstatus(conn) == CONNECTION_BAD)
    {
        cerr << "Connessione al databse fallita " << PQerrorMessage(conn);
        exit(1);
    }

    cout << "La query calcola il bilancio annuo (2020) di ciascuna sede" << endl;

    PGresult * res =  PQexec (conn, "drop view if exists entrate_2020; create view entrate_2020(sede, importo) as select gestito_da_sede as sede, sum(totale) as importo from ordine where data > '2019-12-31' and data < '2021-01-01' group by gestito_da_sede");
    
    res = PQexec (conn, "drop view if exists uscite_2020; create view uscite_2020(sede, importo) as select sede, sum(importo) as importo from( select trasmittente as sede, sum(importo) as importo from stipendio where data > '2019-12-31'and data < '2021-01-01' group by sede UNION select trasmittente as sede, sum(importo) as importo from fattura where data > '2019-12-31'and data < '2021-01-01' group by sede ) as uscite group by sede;");

    res = PQexec (conn, "select * from Entrate_2020 where sede not in (select sede from Uscite_2020 ) UNION select * from Uscite_2020 where sede not in (select sede from Entrate_2020) UNION select Entrate_2020.sede, Entrate_2020.importo - Uscite_2020.importo from Entrate_2020,Uscite_2020 where Entrate_2020.sede = Uscite_2020.sede");

    if(PQresultStatus(res) != PGRES_TUPLES_OK)
    {
      cerr << "Non è stato restituito un risultato " << PQerrorMessage(conn);
      PQclear(res);
      PQfinish(conn);
      exit(1);
    }
    
    int numTuple = PQntuples(res);
    int numAttributi = PQnfields(res);

    for (int i = 0; i < numAttributi; i++)
      cout << setw(8) << PQfname(res,i) << "\t";
    cout<<endl<<endl;

    for ( int i = 0; i < numTuple ; ++ i ) {
      for ( int j = 0; j < numAttributi ; ++ j ) {
        cout << setw(8) << PQgetvalue ( res , i , j )<< "\t";
      }
      cout<<endl;
}

    PQclear(res);
    PQfinish(conn);
    return 0;
}
