# check length and type of key
key_length=$(ssh-keygen -lf $1 | awk -F ':' '{print $1}' | awk '{print $1}')
echo $key_length
key_hash=$(ssh-keygen -lf $1 | awk -F ':' '{print $1}' | awk '{print $2}')
echo $key_hash
key_type=$(ssh-keygen -lf $1 | awk '{print $NF}')
echo $key_type
