package nl.han.duo.gameparadise.repository;

import nl.han.duo.gameparadise.dto.HuurHistorie;
import nl.han.duo.gameparadise.dto.Klant;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface KlantRepository extends CrudRepository<Klant,String> {

    Iterable<Klant> findAllByQuery();

    Iterable<Klant> findByTest();

}

