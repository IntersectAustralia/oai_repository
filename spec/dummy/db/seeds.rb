Instrument.delete_all
Person.delete_all

# Interleave the creation so that the updated_at times don't cluster
Instrument.create!(key: 'p1', name: 'Potentiostat', description: 'PTS')
sleep 1
Instrument.create!(key: 'm1', name: 'multimeter 1', description: 'Yellow one')
sleep 1
Person.create!(key: 'p1', title: 'Dr', given_name: 'Jane', family_name: 'Doe', organisation: 'Intersect Australia Ltd', email: 'jane@example.com')
sleep 1

Instrument.create!(key: 'm2', name: 'multimeter 2', description: 'Orange one')
sleep 1

Person.create!(key: 'p2', title: 'Ms', given_name: 'Jill', family_name: 'Doe', organisation: 'Intersect Australia Ltd', email: 'jill@example.com')
sleep 1
Person.create!(key: 'p1', title: 'Mr', given_name: 'John', family_name: 'Citizen', organisation: 'Intersect Australia Ltd', email: 'john@example.com')
sleep 1

Instrument.create!(key: 'm3', name: 'multimeter 3', description: 'Blue one')
