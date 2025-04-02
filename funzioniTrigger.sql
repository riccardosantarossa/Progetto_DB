
create or replace function checkRepartoProdottoOrdine()
returns trigger as
$$

	begin

		if exists
		(	select 1
			from  prodotto p
			where p.codice = new.prodotto and p.numeroreparto = new.numreparto
		)
		then 
			return new;
		else
			raise notice 'Il reparto non è responsabile del prodotto richiesto';
			return null;
		end if;

	end;

$$ language plpgsql;


create or replace trigger triggerRepartoProdottoOrdine 
before insert or update on ordinereparto
for each row execute procedure checkRepartoProdottoOrdine();

---------------

create or replace function checkProdottoFornitore()
returns trigger as
$$

	begin

		if exists
		(	select 1
			from  fornisce f
			where f.fornitore = new.fornitore and f.prodotto = new.prodotto
		)
		then 
			return new;
		else
			raise notice 'Il fornitre non fornisce il prodotto richiesto';
			return null;
		end if;

	end;

$$ language plpgsql;


create or replace trigger triggerProdottoFornitore 
before insert or update on ordinereparto
for each row execute procedure checkProdottoFornitore();

------------------
create or replace function checkCapoReparto()
returns trigger as
$$

	begin

		if not exists
		(	select 1
			from  reparto r
			where r.numero = old.numero and r.caporeparto = old.cf and r.numero <> new.numero
		)
		then 
			return new;
		else
			raise notice 'La modifica non può essere effettuata';
			return old;
		end if;

	end;

$$ language plpgsql;


create or replace trigger triggerCapoReparto
before update on dipendente
for each row execute procedure checkCapoReparto();

----------------
create or replace function checkAfferenzaCapoReparto()
returns trigger as
$$

	begin

		if exists
		(	select 1
			from  dipendente d
			where new.caporeparto = d.cf and new.numero = d.numeroreparto
		)
		then 
			return new;
		else
			raise notice 'Il dipendente non afferisce al reparto richiesto';
			return null;
		end if;

	end;

$$ language plpgsql;


create or replace trigger triggerAfferenzaCapoReparto
before insert or update on reparto
for each row execute procedure checkAfferenzaCapoReparto();

----------------
create or replace function updateSaldoCliente()
returns trigger as
$$
	declare 
		tot float;
	begin

		create or replace view ordiniSaldi(numero, cliente, prodotto, totaleprodotto)
		as  select cc.numeroordine, cc.cliente, p.codice, (cc.quantita * p.prezzovendita) 
			from checosa cc, prodotto p
			where cc.prodotto = p.codice;

		select sum(totaleprodotto) into tot
		from ordiniSaldi 
		where cliente = new.cliente and numero = new.numeroordine;

		update ordinecliente 
		set saldo = tot
		where numeroordine = new.numeroordine and cliente = new.cliente;

		return new;

	end;

$$ language plpgsql;

create or replace trigger triggerUpdateSaldoCliente 
after insert or update on checosa
for each row execute procedure updateSaldoCliente(); 


create or replace function deleteSaldoCliente()
returns trigger as
$$
	declare 
		tot float;
	begin

		create or replace view ordiniSaldi(numero, cliente, prodotto, totaleprodotto)
		as  select cc.numeroordine, cc.cliente, p.codice, (cc.quantita * p.prezzovendita) 
			from checosa cc, prodotto p
			where cc.prodotto = p.codice;

		select sum(totaleprodotto) into tot
		from ordiniSaldi 
		where cliente = old.cliente and numero = old.numeroordine;

		if tot IS NULL
		then
		
			update ordinecliente 
			set saldo = 0
			where numeroordine = old.numeroordine and cliente = old.cliente;
		
		else
		
			update ordinecliente 
			set saldo = tot
			where numeroordine = old.numeroordine and cliente = old.cliente;
		
		end if;

		return new;

	end;

$$ language plpgsql;

create or replace trigger triggerDeleteSaldoCliente
after delete on checosa
for each row execute procedure deleteSaldoCliente(); 


