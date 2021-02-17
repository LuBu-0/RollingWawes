#include <iostream>
#include "libpq-fe.h"
#include <iomanip>

using std::cin;
using std::cout;
using std::endl;
using std::cerr;
using std::setw;
using std::string;

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

    cout << "La query mostra data una sede, il direttore della sede e l'elenco dei dipendenti che ci lavorano." <<
    endl << "In particolare del direttore verrà mostrata la matricola, il nome e il cognome;" <<
    endl << "della sede verranno mostrati l'id e la città in cui essa si trova;" <<
    endl << "dei dipendenti verranno mostrati la matricola, il nome, il cognome e la mansione svolta." << endl;

    string sede;
    cout << "Elenco sedi: "<<endl<<"LA01\tNY01\tBO01\tTO01\tMI01\tCT01\tPA01\tBE01\tBA01\tAM01\tLO01"<<endl;
    cout << "Inserire il codice di una sede: ";
    cin >> sede;
    while (sede != "LA01" && sede != "NY01" && sede != "BO01" && sede != "TO01" && sede != "MI01" && sede != "CT01" && sede != "PA01" && sede != "BE01" && sede != "BA01" && sede != "AM01" && sede != "LO01")
    {
      cout<<"La sede inserita non è presente nel database." << endl << "Inserisci una sede o premi q per uscire :";
      cin >> sede;
      if(sede == "q")
      {
        PQfinish(conn);
        exit(1);
      }
    }

    string query = "select sede.citta as stabilimento, direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore, R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego from sede, dipendente, dipendente as R1 where sede.direttore = dipendente.matricola and R1.sedeafferita = sede.id and sede.id = $1::varchar UNION select sede.citta as stabilimento, direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore, R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego from sede, dipendente, dipendente as R1, magazzino where sede.direttore = dipendente.matricola and R1.magazzinoafferito = magazzino.id and magazzino.gestore = sede.id and sede.id = $1::varchar EXCEPT select sede.citta as stabilimento, direttore, dipendente.nome as nomeDirettore, dipendente.cognome as cognomeDirettore, R1.matricola as impiegato, R1.nome as nomeImpiegato, R1.cognome as cognomeImpiegato, R1.impiego from sede, dipendente, dipendente as R1 where direttore = R1.matricola order by stabilimento";

    PGresult* stmt = PQprepare (conn, "query", query.c_str(), 1, NULL );
    const char* parameter = sede.c_str();
    PGresult* res = PQexecPrepared (conn, "query", 1, &parameter, NULL, 0, 0);

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
      cout << setw(8) << PQfname(res,i) << "    ";
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
