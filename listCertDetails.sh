while read line
do
    if [ "${line//END}" != "$line" ]; then
        txt="$txt$line\n"
        printf -- "$txt" | openssl x509 -subject -issuer -noout
        txt=""
    else
        txt="$txt$line\n"
    fi
done < $1

### while read line; do if [ "${line//END}" != "$line" ]; then txt="$txt$line\n"; printf -- "$txt" | openssl x509 -subject -issuer -noout; txt=""; else txt="$txt$line\n"; fi; done < file
