%% =====================================================================
%  RETO 2 - MODELADO DEL BALANCE HIBRIDO
%  Proyecto: Sistema Inteligente de Gestion Energetica (SIGE)
%  Curso: Software para Ingenieria (203036) - UNAD
%  Autora: Karen Yulieth Cuellar Murcia
%
%  Proposito: simular un ciclo de 24 horas de una micro-red hibrida.
%  Se modelan la generacion solar, la generacion eolica, la generacion
%  total y la demanda de la comunidad; luego se calcula el balance
%  hora a hora y se grafican la generacion total y la demanda.
%  Todos los vectores son vectores fila de 24 elementos: la posicion k
%  corresponde a la hora k del dia.
%  =====================================================================

clc;          % Limpia la ventana de comandos para ver solo los resultados de esta ejecucion
clear;        % Elimina las variables anteriores del espacio de trabajo
close all;    % Cierra las figuras que hayan quedado abiertas

%% 1. VECTOR DE TIEMPO
horas = 1:24;          % Vector fila [1 2 ... 24]; cada elemento representa una hora del dia

%% 2. PARAMETROS DE DISENO (valores en kW)
Pmax_solar   = 25;     % Potencia pico del arreglo fotovoltaico, alcanzada al mediodia (hora 12)
Pmax_eolica  = 15;     % Potencia nominal maxima de los aerogeneradores; nunca debe superarse
Pmax_demanda = 15;     % Potencia maxima de diseno de la demanda (pico nocturno)

%% a. GENERACION SOLAR
solar = zeros(1, 24);  % Crea el vector solar lleno de ceros: en las horas 1-5 y 19-24 no hay radiacion
% En las horas 6 a 18 se usa media onda senoidal: vale 0 en la hora 5,
% sube hasta 25 kW en la hora 12 (seno = 1) y vuelve a 0 en la hora 19.
% El operador .* no es necesario aqui porque Pmax_solar es un escalar.
solar(6:18) = Pmax_solar * sin(pi * (horas(6:18) - 5) / 14);  % Asigna la curva solo a las posiciones 6 a 18 (indexacion)

%% b. GENERACION EOLICA (AEROGENERADORES)
% Perfil fijo e irregular que imita la variacion de la velocidad del viento.
% Se usan datos fijos (no aleatorios) para que la simulacion sea reproducible.
eolica = [8.2 9.4 10.1 8.7 6.3 0.8 2.4 3.8 5.1 6.6 4.9 7.3 ...
          8.8 10.2 11.6 12.9 13.8 11.4 9.7 10.5 9.2 8.4 9.9 8.8];  % Potencia eolica por hora (kW)
eolica = min(eolica, Pmax_eolica);  % Limitador: si algun valor superara 15 kW, se recorta a la potencia nominal

%% c. GENERACION HIBRIDA TOTAL
generacion_total = solar + eolica;  % Suma elemento a elemento: potencia total disponible en cada hora (kW)

%% d. DEMANDA DE LA COMUNIDAD
dem_madrugada = [3.0 2.6 2.2 2.4 3.1];                      % Horas 1-5: consumo base nocturno entre 2 y 4 kW
dem_diurna    = [7.2 7.6 8.8 9.6 9.2 8.4 7.9 8.1 9.3 9.8 8.7 7.4]; % Horas 6-17: escuela y bombeo agricola, entre 6 y 10 kW
dem_pico      = [12.9 Pmax_demanda 14.6 13.1];              % Horas 18-21: alumbrado publico y retorno a casa; pico de 15 kW en la hora 19
dem_noche     = [3.8 3.3 2.7];                              % Horas 22-24: regreso al consumo base, entre 2 y 4 kW
demanda = [dem_madrugada dem_diurna dem_pico dem_noche];    % Concatena los cuatro tramos en un solo vector de 24 posiciones

%% CALCULO DEL BALANCE ENERGETICO
balance = generacion_total - demanda;    % Positivo = superavit (excedente); negativo = deficit (se usan baterias)
horas_superavit = horas(balance > 0);    % Indexacion logica: horas en que la generacion supera a la demanda
horas_deficit   = horas(balance < 0);    % Indexacion logica: horas en que la demanda supera a la generacion

% Como cada posicion dura 1 hora, sumar potencias (kW) da energia (kWh)
energia_generada = sum(generacion_total);        % Energia total producida en el dia (kWh)
energia_demandada = sum(demanda);                % Energia total consumida por la comunidad (kWh)
energia_baterias = -sum(balance(balance < 0));   % Energia que deben entregar las baterias en las horas de deficit (kWh)

% Muestra un resumen en la ventana de comandos
disp('Horas con superavit de energia:');   % Titulo del primer resultado
disp(horas_superavit);                     % Lista de horas con excedente
disp('Horas con deficit de energia:');     % Titulo del segundo resultado
disp(horas_deficit);                       % Lista de horas que requieren respaldo de baterias
fprintf('Energia generada en el dia: %.2f kWh\n', energia_generada);     % Imprime la energia generada con 2 decimales
fprintf('Energia demandada en el dia: %.2f kWh\n', energia_demandada);   % Imprime la energia demandada con 2 decimales
fprintf('Energia requerida de baterias: %.2f kWh\n', energia_baterias);  % Imprime la energia que cubren las baterias

%% e. VISUALIZACION GRAFICA
figure('Name', 'Balance hibrido SIGE', 'Color', 'w');      % Abre una ventana de figura con fondo blanco
plot(horas, generacion_total, '-o', 'Color', [0 0.45 0.74], ...
     'LineWidth', 2, 'MarkerFaceColor', [0 0.45 0.74]);    % Curva de generacion total en azul con marcadores circulares
hold on;                                                    % Mantiene la grafica para superponer la siguiente curva
plot(horas, demanda, '-s', 'Color', [0.85 0.33 0.10], ...
     'LineWidth', 2, 'MarkerFaceColor', [0.85 0.33 0.10]);  % Curva de demanda en naranja con marcadores cuadrados
hold off;                                                   % Libera la figura

title('Balance energetico de la micro-red hibrida SIGE - ciclo de 24 horas'); % Titulo del grafico
xlabel('Tiempo (horas)');                % Etiqueta del eje X
ylabel('Potencia (kW)');                 % Etiqueta del eje Y
grid on;                                 % Activa la cuadricula de fondo
legend('Generacion total (solar + eolica)', 'Demanda de la comunidad', ...
       'Location', 'northwest');         % Leyenda que identifica cada curva, ubicada arriba a la izquierda
xlim([1 24]);                            % Limita el eje X al ciclo de 1 a 24 horas
ylim([0 40]);                            % Deja margen superior para que la leyenda no tape las curvas
set(gca, 'XTick', 1:24);                 % Muestra una marca por cada hora en el eje X
