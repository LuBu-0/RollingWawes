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
    
    cout << "La query mostrare a schermo il miglior autista (quello che ha effettuato più consegne) dell'azienza." <<
    endl << "indicandone nome, cognome, matricola e la sede nella quale egli è impiegato." << endl;

    PGresult * res = PQexec (conn, "select dipendente.matricola, dipendente.nome, dipendente.cognome, sede.id as Sede from (select max(dipendente) as matricola from (select dipendente, count(Cliente) from consegna group by dipendente) as ID) as migliorAutista, dipendente, magazzino, sede where migliorAutista.matricola=Dipendente.matricola and dipendente.magazzinoAfferito = magazzino.id and magazzino.gestore = sede.id");

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
