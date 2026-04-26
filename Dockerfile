# ──────────────────────────────────────────────
# Bazowy obraz Python 3.12 slim (Debian)
# ──────────────────────────────────────────────
FROM python:3.12-slim

# Autor obrazu
LABEL maintainer="bauraa"

# Nie buforuj logów Pythona, wyświetlaj je od razu
ENV PYTHONUNBUFFERED=1

# ──────────────────────────────────────────────
# Kopiowanie i instalacja zależności
# ──────────────────────────────────────────────
# Kopiujemy tylko requirements.txt (Docker cache!)
COPY requirements.txt /tmp/requirements.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt
# nadpisywanie wartości DEV podczas budowania obrazu
ARG DEV=false 
# domyślnie false, można ustawić na true podczas budowania obrazu, np.:

# Instalacja pip, zależności i czyszczenie tmp
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then pip install --no-cache-dir -r /tmp/requirements.dev.txt; fi && \     
    # jeśli DEV=true, zainstaluj dodatkowe zależności developerskie
    rm -rf /tmp

#Podczas instalacji pakiety pip czasowo zapisuje pliki w katalogu /tmp. Jeśli ich tam zostawimy:
#obraz Dockera staje się większy (kilkadziesiąt MB dodatkowych plików)
#pliki tymczasowe są niepotrzebne w gotowym kontenerze
#rm = remove
#-rf = rekursywnie, bez pytania, wszystkie pliki i foldery w /tmp
#Dzięki temu obraz jest lżejszy i czystszy



# ──────────────────────────────────────────────
# Tworzenie bezpiecznego użytkownika
# ──────────────────────────────────────────────
RUN adduser --disabled-password --no-create-home django-user


#Domyślnie w kontenerze Docker uruchamiasz procesy jako root:
# Root = pełne uprawnienia do całego systemu w kontenerze
# Jeśli ktoś np. złamie aplikację, ma pełny dostęp do kontenera
# Rozwiązanie: tworzymy użytkownika, który nie ma hasła i nie ma katalogu domowego:
# W Dockerfile potem możemy uruchomić proces Django jako django-user, np.:
# USER django-user
# Dzięki temu nawet jeśli ktoś przełamie serwer, nie będzie miał uprawnień root, co zwiększa bezpieczeństwo.

USER django-user


# ──────────────────────────────────────────────
# Kopiowanie całego kodu aplikacji
# ──────────────────────────────────────────────
COPY . /app /app

# Katalog roboczy
WORKDIR /app

# Port serwera Django
EXPOSE 8000

# Domyślna komenda uruchamiająca serwer (opcjonalna)
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]