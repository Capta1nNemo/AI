alter table doctors add constraint pk_doc primary key (id);
alter table requests add constraint fk_doc_id foreign key (doctor_id) references doctors(id);

