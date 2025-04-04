/*Dadas as 3 tabelas:

students: (id int, name text, enrolled_at date, course_id text)
courses: (id int, name text, price numeric, school_id text)
schools: (id int, name text)
Considere que todos alunos se matricularam nos respectivos cursos e que price é o valor da matrícula, pago por cada aluno.

a) Escreva uma consulta PostgreSQL para obter, por nome da escola e por dia, a quantidade de alunos matriculados e o valor total das matrículas,
tendo como restrição os cursos que começam com a palavra “data”. Ordene o resultado do dia mais recente para o mais antigo.

b) Utilizando a resposta do item a, escreva uma consulta para obter, por escola e por dia, a soma acumulada, 
a média móvel 7 dias e a média móvel 30 dias da quantidade de alunos. 

tabelas utilizadas para construção do script:

courses
schools
students
*/


/*Consulta para obtenção das informações: nome da escola, quantidade de alunos matriculados, 
e o valor total pago em matrículas matrículas considerando cursos que começam com 'Data' - Questão A*/

select                                                 /*Seleção do nome da esola, data e quantidade de alunos matriculados*/
	schools.name as escola,
	students.enrolled_at as data_matricula,
	count(students.enrolled_at) as qtd_matricula,       /*Quantidade de alunos matriculados na data*/
	sum(courses.price) as vlr_total_matricula           /*Valor total das matrículas no dia (preço * número de alunos)*/

from students
inner join courses on students.course_id = courses.id  /*Junção de alunos com cursos em que se matricularam*/
inner join schools on courses.school_id = schools.id   /*Junção de cursos com escolas que os oferecem*/
where courses.name like 'Data%'                        /*Filtrando cursos com nome 'Data'*/
group by schools.name, students.enrolled_at            /*Agrupamento por escola e data de matrícula*/
order by students.enrolled_at desc;                    /*Ordena data de matricula do dia mais recente para o mais antigo*/


/*Consulta para obtenção da média movel de 7 e 30 dias - Questão B*/
/*Utilizando uma CTE - Common Table Expression para organoizar as matrículas por escola e data, considerando os cursos que começam com 'Data'*/
/*Obs: CTE utilizando a primeira consulta com excessão da condição de soma*/
with enrollmentdata as (
    select                                           
        schools.name as escola,
        students.enrolled_at as data_matricula,
        count(students.enrolled_at) as qtd_matricula 
from students
inner join courses on students.course_id = courses.id 
inner join schools on courses.school_id = schools.id  
where courses.name like 'Data%'                       
group by schools.name, students.enrolled_at           
)
select                                                /*Seleção de nome da escola, data de matrícula e quantidade de alunos matriculados*/
    escola,
    data_matricula,
    qtd_matricula,
    sum(qtd_matricula) over (partition by escola order by data_matricula) as soma_acumulada,                                                /*Soma acumulada de matrículas por escola ao longo do tempo*/
    avg(qtd_matricula) over (partition by escola order by data_matricula rows between 6 preceding and current row) as media_movel_7dias,   /*Média móvel de 7 dias da quantidade de matrículas por escola*/
    avg(qtd_matricula) over (partition by escola order by data_matricula rows between 29 preceding and current row) as media_movel_30dias /*Média móvel de 30 dias da quantidade de matrículas por escola*/
from enrollmentdata
order by escola, data_matricula; /*Ordenando resultado final por escola e data de matrícula*/


