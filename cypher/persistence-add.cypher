MERGE (s:Student:Lab {studentId:'s04'}) SET s.name='Daria', s.isActive=true;
MATCH (s:Student:Lab) RETURN s.studentId, s.name ORDER BY s.studentId;
