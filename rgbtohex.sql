--Postgresql rgb to hex color converter function

CREATE OR REPLACE FUNCTION rgbtohex(_rgb text) RETURNS text AS $$
	declare rgbarr text[];
	red text;
	green text;
	blue text;
	
        BEGIN
		select regexp_split_to_array(_rgb, ',') into rgbarr;
		red = to_hex(rgbarr[1]::integer);
		green = to_hex(rgbarr[2]::integer);
		blue = to_hex(rgbarr[3]::integer);

		if length(red) = 1 then
		red = '0' || red;
		END IF;

		if length(green) = 1 then
		green = '0' || green;
		END IF;

		if length(blue) = 1 then
		blue = '0' || blue;
		END IF;
                RETURN '#' || red || green || blue;
        END;
$$ LANGUAGE plpgsql;

SELECT mobiliz_rgbtohex('0, 51, 255');
