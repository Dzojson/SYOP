function Get-File{
    param (
        [Parameter(Mandatory = $true, Position = 0)] #parametr obowiązkowy ścieżki
        [string] $Path, #zmienna typu string przechowywujący ścieżke
        [Parameter(Mandatory = $true, Position = 0)] #parametr obowiązkowy typu rozszerzenia
        [string] $FileType #zmienna typu string przechowywujący typ rozszerzenia
    )
    $PathList = Get-ChildItem -Path $Path -Recurse -Include *.$FileType #Polecenie Get-ChildItem pobierające elementy 
    foreach ($paths in $PathList) { # Iteracja po scieżkach katalogów
        $directories = $paths.DirectoryName.Split("\") #rozdzielenie scieżki znakiem "\"
        $Level = [int]$directories.GetUpperBound(0) #zwraca ineks ostaniego elementu 
        $count = 0
        foreach($word in $directories){#rysowanie drzewa katalogów
            if($count -eq 0){
                Write-Host $word 
            }
            else {
                Write-Host ("   "*($count - 1) + '|___') $word #wypisanie katalogów
            }
            if($count -eq $Level){
                Write-Host ("   "*($count) + '|___')$paths.Name $paths.LastWriteTime ($paths.Length/ 1MB) MB #wypisanie nazwy pliku, ostaniej daty modyfikacji oraz rozmiar

            }
            $count = $count + 1
        }
    }
}

Get-File -Path D:\ -FileType docx #wywołanie funkcji