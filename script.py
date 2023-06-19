from random import randint
import pandas as pd

personne = pd.read_csv("personne.csv", index_col=0)
personne['id_utilisateur'] = range(1,len(personne)+1)
personne.to_csv('Script/personne.csv')

relation_groupe_concert_passe=pd.DataFrame({'id_concert': [], 'id_groupe': []})
relation_groupe_concert_passe['id_concert']=range(1,31)

grp=[]
for i in range(30):
    grp.append(randint(1, 20))

relation_groupe_concert_passe['id_groupe']= grp


relation_groupe_concert_passe.set_index("id_concert", inplace=True, drop=True)
relation_groupe_concert_passe.to_csv('Script/relation_groupe_concert_passe.csv')
print(relation_groupe_concert_passe)