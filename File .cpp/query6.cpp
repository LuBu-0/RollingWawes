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

    cout << "Mostrare la top 5 degli articoli più venduti durante l'anno corrente (2020)." <<
    endl << "In particolare si mostrino:" <<
    endl << "L'ID, il tipo, e la marca del prodotto e quanti pezzi ne sono stati venduti" << endl;

    PGresult * res = PQexec (conn, "SELECT merce.id, merce.tipo, merce.marca, COUNT(*) AS quantita FROM merce, composizione_ordine, ordine WHERE merce.id = composizione_ordine.prodotto AND composizione_ordine.ordine = ordine.numeroOrdine AND ordine.data > '2019-12-31' AND ordine.data < '2021-01-01' AND ordine.annullato = 'false' GROUP BY (merce.id, merce.tipo, merce.marca) ORDER BY quantita DESC LIMIT 5");
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
