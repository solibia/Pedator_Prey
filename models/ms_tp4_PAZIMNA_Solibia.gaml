/**
* Name: mstp4PAZIMNASolibia
* Author: basile
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model mstp4PAZIMNASolibia

global {
	/** Insert the global definitions, variables and actions here */
//	int Nbre_De_Nid <- 1 parameter: "Nbre de nid";
//	int Nbre_de_Nouriture <- 5 parameter: "Nbre nourriture";	
//	int Nbre_de_Fourmis <- 30 parameter: "Nbre fourmi";	
//	int Dure_de_marque <- 30 parameter: "Nbre marque";	
	float max_size_agneau <- 4.0;
	float min_size_agneau <- 1.0;
	float max_size_loup <- 5.0;
	float min_size_loup <- 1.0;
	float max_size_herbe <- 3.50;
	float min_size_herbe <- 0.5;
		
	init {
		create Herbe number: 7{
			couleur  <- #green;
			size <- min_size_herbe;
		}
		create Agneau number: 10{
			couleur  <- #yellow;
			size <- min_size_agneau;			
		}	
		create Loup number: 10{
			couleur  <- #red;
			size <- min_size_loup;			
		}			
	}	
}

species SpeedAbsract {
	point location;
	rgb couleur;
	float size;
	float speed_grow;
	float speed_double <- 10.0; 
}
species Herbe parent: SpeedAbsract{
	float min_size  <- min_size_herbe;
	float max_size  <- max_size_herbe;
	int count_double <- 0;
	reflex vivre {
		//Augmenter la taille si elle est < max_size
		if(size < max_size){
			size  <- size+0.1; //*(max_size_agneau/(max_size_agneau+min_size_agneau));
		}
		//si (taille >  min_size) alors augmenter count_double;
		if(size >  min_size){
			count_double <- count_double+1; 
		}
	}
	
	reflex creer_enfant when:(size > min_size) and (count_double > speed_double){
		//si les 4 voisins location:s'il y en a une est libre alors creer herbe enfant
		create Herbe number:1{
			couleur  <- #green;	
			//taille est minimal générale
			size  <- min_size;
			//location à coté
			//location  <- location+0.50;
		}
		count_double  <- 0;
	}
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}

species Animal parent: SpeedAbsract{
	float eat_capable;
	float hungry_state;
	float max_age <- rnd(200.0)+20;
	float current_age <- 0.0;
	float max_hungry <- 25.0;
	float max_hungry_time <- 25.0;
	float current_hungry_time <- 0.0;
	float rayon_observation <- 1.0;
	float speed <- 1.0;
	float speed_consomation <- 3.0;
	
}

species Agneau skills:[moving] parent: Animal{
	int count_double <- 0;

	reflex vivre {
		//Si la taille   <  max_size  alors augmenter la taille 
		if(size < max_size_agneau){
			size  <- size+0.1; //*(max_size_agneau/(max_size_agneau+min_size_agneau));
		}
		//augmenter l'age
		current_age <- current_age+1;
		//si age > max_age, alors il est mort
		if(current_age > max_age){
			do die;
		}
		//Diminuer hungry_state avec un montant: speed_consommation
		hungry_state <- hungry_state - speed_consomation;
		//Si hungry_state >=0 alors commencer compter count_hungry
		if(hungry_state > 0){
			current_hungry_time <- current_hungry_time+1;
			//Se deplacer vers l'herbe
			do goto target: one_of(Herbe);			
		}		
		//Si count_hungry > max_hungry_time alors il est mort
		if(current_hungry_time > max_hungry_time){
			do die;
		}		
		//Se deplacer par hazard
		do action: wander amplitude: 180;
		//do goto target: one_of(Herbe);
	}
	
	reflex chercher_manger when:(hungry_state < max_hungry){
		//Oserver les herbes herbes assez grands dans rayon d'observation
		//let list_herbes value:  (list(Herbe)sort_by(self distance_to each));
		let list_herbes <- list (Herbe) where (each distance_to self < rayon_observation);
		
		if(length(list_herbes)> 0 ){
			let herbe_mange <- first(list_herbes);
			//manger: augmenter hungry_state avc montant de taille de herbe
			ask herbe_mange{
				//set taille = min_size
				set size <- min_size;
			}
			//si count_hungry > 0 alors mettre à 0
			if(current_hungry_time> 0){
				current_hungry_time <-0;  
			}			
		}
	}
	
	reflex creer_enfant when:(size > min_size_agneau) and (count_double > speed_double){
		create Agneau number:1{
			//taille est minimal générale
			size  <- min_size_agneau;
			location  <- self.location;
			couleur <- #yellow;
		}
		count_double  <- 0;		
	}
	
	aspect basic {
		draw square(size) color:couleur;
	}
}

species Loup skills:[moving] parent: Animal{
	int count_double <- 0;

	reflex vivre {
		//Si la taille   <  max_size  alors augmenter la taille 
		if(size < max_size_loup){
			size  <- size+0.1; //*(max_size_agneau/(max_size_agneau+min_size_agneau));
		}
		//augmenter l'age
		current_age <- current_age+1;
		//si age > max_age, alors il est mort
		if(current_age > max_age){
			do die;
		}
		//Diminuer hungry_state avec un montant: speed_consommation
		hungry_state <- hungry_state - speed_consomation;
		//Si hungry_state >=0 alors commencer compter count_hungry
		if(hungry_state > 0){
			current_hungry_time <- current_hungry_time+1;
			//Se deplacer vers l'agneau
			do goto target: one_of(Agneau);			
		}		
		//Si count_hungry > max_hungry_time alors il est mort
		if(current_hungry_time > max_hungry_time){
			do die;
		}		
		//Se deplacer par hazard
		do action: wander amplitude: 180;
	}
	
	reflex chercher_manger when:(hungry_state < max_hungry){
		//Oserver les herbes herbes assez grands dans rayon d'observation
		//let list_herbes value:  (list(Herbe)sort_by(self distance_to each));
		let list_agneau <- list (Agneau) where (each distance_to self < rayon_observation);
		if(length(list_agneau)> 0 ){
			let agneau_mange <- first(list_agneau);
			//manger: augmenter hungry_state avc montant de taille de herbe
			ask agneau_mange{
				do die;
			}
			//si count_hungry > 0 alors mettre à 0
			if(current_hungry_time> 0){
				current_hungry_time <-0;  
			}			
		}
	}
	
	reflex creer_enfant when:(size > min_size_loup) and (count_double > speed_double){
		create Loup number:1{
			//taille est minimal générale
			size  <- min_size_loup;
			location  <- self.location;
			couleur <- #yellow;
		}
		count_double  <- 0;		
	}
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}


experiment mstp4PAZIMNASolibia type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display mstp4PAZIMNASolibia {
			species Herbe aspect: basic;
			species Agneau aspect: basic;
			species Loup aspect: basic;
		}		
	}
}
