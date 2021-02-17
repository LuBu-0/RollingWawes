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

    cout << "La query applica uno sconto del 20% a tutti i prodotti invenduti durante l'anno corrente (2020)." <<
    endl << "il risultato viene mostrato ordinando il prezzo di tutti i prodotti in ordine decrescente." << endl;
    
    PGresult * res = PQexec (conn, "update merce set prezzo = prezzo-(prezzo*20)/100 where ID in (select ID from merce EXCEPT select prodotto from composizione_ordine join ordine on ordine.numeroOrdine = composizione_ordine.ordine where data > '2019-12-31')");

    res = PQexec (conn, "select * from merce order by prezzo desc");
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
      cout << setw(8) << PQfname(res,i) << "\t\t";
    cout<<endl<<endl;

    for ( int i = 0; i < numTuple ; ++ i ) {
      for ( int j = 0; j < numAttributi ; ++ j ) {
        cout << setw(8) << PQgetvalue ( res , i , j )<< "\t\t";
      }
      cout<<endl;
}

    PQclear(res);
    PQfinish(conn);
    return 0;
}
