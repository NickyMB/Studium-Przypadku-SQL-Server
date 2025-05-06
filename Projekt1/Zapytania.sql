SELECT DISTINCT P.ID, (P.Imie + ' ' + P.Nazwisko) AS Pacjent,D.Imie from Patients P join Appointments A on P.ID = A.PatientsID join Doctors D on A.DoctorsID = D.ID where D.ID = 2
SELECT * from Appointments


SELECT A.Data AS DataWizyty, A.Diagnoza ,A.ID IdWizyty
              FROM Appointments A 

UPDATE Appointments SET Diagnoza = 'Appointments' WHERE ID = 26

select * from Appointments

SELECT T.TypBadania, T.Wynik, T.Data
              FROM LabTest T
              WHERE T.AppointmentsID = 1

select M.Nazwa, P.Dawka, P.Dawkowanie FROM Prescriptions P JOIN Medications M ON P.KodLeku = M.ID join Patients Pa on Pa.ID = P.PatientsId join Appointments A on A.PatientsID = Pa.ID where A.ID = 1


select distinct M.Nazwa UNazwa, M.ID UId from Medications M
          


          SELECT Prescriptions.ID,Medications.Nazwa NazwaLeku, KodLeku, Dawka, Dawkowanie
              FROM Prescriptions
              join Patients on Patients.ID = Prescriptions.PatientsId
              join Appointments on Appointments.PatientsID = Patients.ID
              join Medications on Medications.ID = Prescriptions.KodLeku
              WHERE Appointments.ID = 2
INSERT INTO Prescriptions (KodLeku, Dawka, Dawkowanie, PatientsId) VALUES (4, '1mg', 'rocznie', 2)

INSERT INTO LabTest (AppointmentsID, TypBadania, Wynik, Data) VALUES (2, 'Test Krwi', 'git', '2023-10-01')

select avg(AppointmentCount) as AvgAppointments, PatientsID
from (
    select count(*) as AppointmentCount, PatientsID
    from Appointments
    group by PatientsID
) as SubQuery
group by PatientsID

select * from AverageTestPerPatient()

select avg(AppointmentCount) as AvgAppointments, DoctorsID
from (
    select count(*) as AppointmentCount, DoctorsID
    from Appointments
    group by DoctorsID
) as SubQuery
group by DoctorsID

INSERT INTO Prescriptions (KodLeku, Dawka, Dawkowanie, PatientsId) VALUES (4, '1mg', 'rocznie', 2)