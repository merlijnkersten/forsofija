### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 1261ff50-c83b-11eb-33f5-4dd7a6544e38
using Images, LinearAlgebra, Statistics, DataFrames, Random, Plots

# ╔═╡ 25ebcde0-416b-440a-9c00-4589c200ef64
md"""
# Hapy birthday Sofija!
I had some fun this morning with your collage birthday present request. I'm not sure if you know this, but for the past three years I've taken a [picture every day](https://merlijnkersten.nl/soloespresso). I was going to make some sort of collage out of those, when I got an idea to do something slightly different while reading about [statistics in Julia](https://statisticswithjulia.org/) (p.31-36). They described a simple algorithm for approximating pi, using a random sample of points (x,y) (with x,y in [0,1]) and then using the ratio of the number of points falling within the unit circle to the total number of points to approximate pi:
```math
	\hat{\pi} = 4\cdot\frac{\textrm{Number of points with } x^2+y^2\leq 1}{\textrm{Total number of points}}
```
This got me thinking: what if I used the RGB-values of the pixels of my photos to approximate pi, and find the pictures of the last year whose RGB-values came closest to approximating pi? Since we've got three values (red, green, blue), we're now dealing with the proportion of points that falls within (an eight) of the unit sphere:
```math
	\hat{\pi} = 6\cdot\frac{\textrm{Number of points with } r^2+g^2+b^2\leq 1}{\textrm{Total number of points}}.
```
Before we get started, let's remind ourselves of what we expect to find:
"""

# ╔═╡ 5c0aaed1-f9b1-4344-b856-e71aa682a496
pi

# ╔═╡ a4a81b1d-96e0-431d-9283-9408a4f51e81
md"""The following function implements the approach shown above: it takes an image (using Julia's Images package), calculates which of its pixels (or points) are in the unit sphere, and uses that to return an approximation to pi.
"""

# ╔═╡ 9a2306ab-5c41-48d6-9052-014d7cdae4ef
function piApprox(img)
	imgInSphere = filter((p)-> (norm(p) <1), img) # Find points within unit sphere
	piApprox = 6*length(imgInSphere)/length(img)  # Find approx pi through ratio
	piApprox 									  # Return approx pi
end

# ╔═╡ 53742924-32ba-49c0-827d-8571a049429e
md"""
The code snippet below tests this function for a sample of 365 random 550x800 RGB images (about the average size of my photos). The mean approximation of pi is quite close to the actual value of pi!
"""

# ╔═╡ 3ab4ce37-faf9-436d-831e-13cc2c5d7e3e
rand(RGB, 550, 800)

# ╔═╡ 197ac750-76b4-4a0b-abcd-c44585332eaa
begin
	img_array_test = [rand(RGB, 550, 800) for _ in 1:365]
	piApprox_array_test = [piApprox(i) for i in img_array_test]
	mean(piApprox_array_test)
end

# ╔═╡ 56f8e95b-7c66-442e-b28c-4dd71441e7fa
md"""So let's now try this with my actual photos. I last updated my photos a few weeks ago so I used the photos from May 25 2020 to May 24 2021 (you can find them in the `Images May 25 2020 - May 24 2021` folder [here](https://github.com/merlijnkersten/forsofija)), all of which have a maximum width of 550 pixels (so running this snippet shouldn't fry your computer).
"""

# ╔═╡ 8b6918b8-8a46-4601-8da2-50a10a8f0363
begin
	directory = "C:/Users/Merlijn Kersten/Desktop/Images May 25 2020 - May 24 2021/"
	img_array = [load(directory * img) for img in readdir(directory)]
	piApprox_dct = [[i, piApprox(i), abs(piApprox(i) - pi)] for i in img_array]
	piApprox_df = DataFrame(piApprox_dct, :auto)
end

# ╔═╡ e5b5e575-7937-4115-ab4a-34cd71c1ed4b
md"""The DataFrame we created in the last snippet needs some polishing, so we transpose it ([thank you StackOverflow](https://stackoverflow.com/questions/37668312/transpose-of-julia-dataframe/59485866#59485866)), rename the columns we need, and sort the DataFrame by how closely the RGB-values of the photo approximate pi:
"""

# ╔═╡ 55d91be5-a279-4480-b226-d7dbfd337de5
begin
	piApprox_dft = DataFrame([[names(piApprox_df)]; collect.(eachrow(piApprox_df))], [:column; Symbol.(axes(piApprox_df, 1))])
	rename!(piApprox_dft, :2 => "photo", :3 => "piApprox", :4 =>"abs(piApprox - pi)")
	select!(piApprox_dft, Not(:"column"))
	sort!(piApprox_dft, [:"abs(piApprox - pi)"])
end

# ╔═╡ da79b5ce-8ffa-4c81-a470-bfed1fb2530d
md"""
The first few pictures actually give quite close approximations of pi! (Although this was perhaps to be expected given the large sample). The first picture is from the Old Naval College in Greenwhich, taken on 29 May 2020. The second is the well-stocked boozeshelf of my old appartment from 7 January 2021 and the third shows Max and Moon in Wales on 17 April 2021. 

If you scroll further down, you'll see that the approximations quickly deteriorate; this is confirmed by a quick histogram:
"""

# ╔═╡ 6d6d1650-9ff6-4771-ae9f-1a7f764adaae
histogram(piApprox_dft[!, :"piApprox"], bins=:scott, title="Distribution of approximation to pi")

# ╔═╡ 00a5bb16-c9d9-46a0-9969-8181195d8e81
mean(piApprox_dft[!, :"piApprox"]), std(piApprox_dft[!, :"piApprox"])

# ╔═╡ 03e1d27f-f178-4a22-ab75-1f6d0978cd16
md"""The mean of the approximation is a whopping 51.5% larger than pi. This strongly suggests that this is perhaps not a great way to estimate pi (the ancient Babylonians approximated pi to [within one percent](https://en.wikipedia.org/wiki/Pi#History) over 3,500 years ago). When I take my daily pictures, I don't aim for a random sample of RGB-pixels of course. The skew of the distribution of the approximation to pi suggests that my pictures are, generally speaking, less saturated than a random sample. This raises many questions. Should I have corrected my RGB values for how human vision sees RGB values (see [this video](https://www.youtube.com/watch?v=h9j89L8eQQk) for some examples of mismatch between RGB values and human vision)? Is there a pattern to the pictures that give a close approximation to pi? How will this innovative research help us mitigate climate change and save us from malificent AI? So many unknowns!

I have sat behind my laptop for far too long typing up this Pluto notebook (I should have been filing my taxes), and I still I am not sure whether this counts as a 'collage', so I'll leave you with my twenty best pi-approximating photos of the last year. Happy birthday, and hope to see you soon!
"""

# ╔═╡ efc59c96-60e8-4f80-9595-99acc043c9a5
first(piApprox_dft, 20)[!, :"photo"]

# ╔═╡ Cell order:
# ╠═1261ff50-c83b-11eb-33f5-4dd7a6544e38
# ╠═25ebcde0-416b-440a-9c00-4589c200ef64
# ╠═5c0aaed1-f9b1-4344-b856-e71aa682a496
# ╠═a4a81b1d-96e0-431d-9283-9408a4f51e81
# ╠═9a2306ab-5c41-48d6-9052-014d7cdae4ef
# ╠═53742924-32ba-49c0-827d-8571a049429e
# ╠═3ab4ce37-faf9-436d-831e-13cc2c5d7e3e
# ╠═197ac750-76b4-4a0b-abcd-c44585332eaa
# ╠═56f8e95b-7c66-442e-b28c-4dd71441e7fa
# ╠═8b6918b8-8a46-4601-8da2-50a10a8f0363
# ╠═e5b5e575-7937-4115-ab4a-34cd71c1ed4b
# ╠═55d91be5-a279-4480-b226-d7dbfd337de5
# ╠═da79b5ce-8ffa-4c81-a470-bfed1fb2530d
# ╠═6d6d1650-9ff6-4771-ae9f-1a7f764adaae
# ╠═00a5bb16-c9d9-46a0-9969-8181195d8e81
# ╠═03e1d27f-f178-4a22-ab75-1f6d0978cd16
# ╠═efc59c96-60e8-4f80-9595-99acc043c9a5
