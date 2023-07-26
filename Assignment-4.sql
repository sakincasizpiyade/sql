---CREATE DATABASE Manufacturer;

create table Product (
    prod_id INT PRIMARY KEY,
    prod_name VARCHAR(50),
    quantity INT 
);


create table Component (
    comp_id INT PRIMARY KEY,
    comp_name VARCHAR(50),
    description VARCHAR(50),
    quantity_comp INT 
);


create table Prod_Comp (
    prod_id INT,
    comp_id INT,
    quantity_comp INT,
    PRIMARY KEY(prod_id , comp_id),
    FOREIGN KEY (prod_id) REFERENCES product (prod_id),
    FOREIGN KEY (comp_id) REFERENCES component (comp_id)
);



create table Supplier (
    supp_id INT PRIMARY KEY,
    supp_name VARCHAR(50),
    supp_location VARCHAR(50),
    supp_country VARCHAR(50),
    is_active BIT
);


create table Comp_Supp (
    supp_id INT,
    comp_id INT,
    order_date DATE,
    quantity INT,
    PRIMARY KEY(supp_id , comp_id),
    FOREIGN KEY (comp_id) REFERENCES component (comp_id),
    FOREIGN KEY (supp_id) REFERENCES supplier (supp_id)
);

